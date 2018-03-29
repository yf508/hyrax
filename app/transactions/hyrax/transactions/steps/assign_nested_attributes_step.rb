require "dry/transaction/operation"

module Hyrax
  module Transactions
    module Steps
      class AssignNestedAttributesStep
        include Dry::Transaction::Operation

        def call(env)
          assign_nested_attributes_for_collection(work: env[:work], ability: env[:ability], attributes: env[:attributes])
          Success(env)
        end

        private

          ##
          # Attaches any unattached members.  Deletes those that are marked _delete
          #
          # @param env [Hyrax::Actors::Enviornment]
          # @return [Boolean]
          #
          # rubocop:disable Metrics/MethodLength
          # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          def assign_nested_attributes_for_collection(work:, ability:, attributes:)
            attributes_collection = attributes.delete(:member_of_collections_attributes)
            collection_ids = attributes.delete(:member_of_collection_ids)
            return assign_for_collection_ids(work: work, ability: ability, collection_ids: collection_ids) unless attributes_collection

            emit_deprecation if attributes.delete(:member_of_collection_ids)

            return false unless
              valid_membership?(work: work, collection_ids: attributes_collection.map { |_, attributes| attributes['id'] })

            attributes_collection = attributes_collection.sort_by { |i, _| i.to_i }.map { |_, attributes| attributes }
            # checking for existing works to avoid rewriting/loading works that are already attached
            existing_collections = work.member_of_collection_ids
            attributes_collection.each do |attributes|
              next if attributes['id'].blank?
              if existing_collections.include?(attributes['id'])
                remove(work: work, id: attributes['id']) if has_destroy_flag?(attributes)
              else
                add(work: work, ability: ability, id: attributes['id'])
              end
            end

            true
          end
          # rubocop:enable Metrics/MethodLength
          # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

          ##
          # @deprecated supports old :member_of_collection_ids arguments
          def emit_deprecation
            Deprecation.warn(self, ':member_of_collections_attributes and :member_of_collection_ids were both ' \
                                   ' passed. :member_of_collection_ids is ignored when both are passed and is ' \
                                   'deprecated for removal in Hyrax 3.0.')
          end

          ##
          # @deprecated supports old :member_of_collection_ids arguments
          def assign_for_collection_ids(work:, ability:, collection_ids:)
            return false unless valid_membership?(work: work, collection_ids: collection_ids)

            if collection_ids
              Deprecation.warn(self, ':member_of_collection_ids has been deprecated for removal in Hyrax 3.0. ' \
                                     'use :member_of_collections_attributes instead.')

              other_collections = collections_without_edit_access(work: work, ability: ability)

              collections = ::Collection.find(collection_ids)
              raise "Tried to assign collections with ids: #{collection_ids}, but none were found" unless
                collections

              work.member_of_collections = collections
              work.member_of_collections.concat(other_collections)
            end

            true
          end

          ##
          # @deprecated supports old :member_of_collection_ids arguments
          def collections_without_edit_access(work:, ability:)
            work.member_of_collections.select { |coll| ability.cannot?(:edit, coll) }
          end

          # Adds the item to the ordered members so that it displays in the items
          # along side the FileSets on the show page
          def add(work:, ability:, id:)
            collection = Collection.find(id)
            return unless ability.can?(:deposit, collection)
            work.member_of_collections << collection
          end

          # Remove the object from the members set and the ordered members list
          def remove(work:, id:)
            collection = Collection.find(id)
            work.member_of_collections.delete(collection)
          end

          # Determines if a hash contains a truthy _destroy key.
          # rubocop:disable Naming/PredicateName
          def has_destroy_flag?(hash)
            ActiveFedora::Type::Boolean.new.cast(hash['_destroy'])
          end
          # rubocop:enable Naming/PredicateName

          def valid_membership?(work:, collection_ids:)
            multiple_memberships = Hyrax::MultipleMembershipChecker.new(item: work).check(collection_ids: collection_ids)
            if multiple_memberships
              work.errors.add(:collections, multiple_memberships)
              return false
            end
            true
          end
      end
    end
  end
end
