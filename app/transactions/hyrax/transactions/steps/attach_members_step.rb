require "dry/transaction/operation"

module Hyrax
  module Transactions
    module Steps
      class AttachMembersStep
        include Dry::Transaction::Operation

        def call(env)
          attributes_collection = env[:attributes].delete(:work_members_attributes)
          assign_nested_attributes_for_collection(env[:work], env[:ability], attributes_collection: attributes_collection)
          Success(env)
        end

        private

          # Attaches any unattached members.  Deletes those that are marked _delete
          # @param [Hash<Hash>] a collection of members
          def assign_nested_attributes_for_collection(work:, ability: attributes_collection:)
            return true unless attributes_collection
            attributes_collection = attributes_collection.sort_by { |i, _| i.to_i }.map { |_, attributes| attributes }
            # checking for existing works to avoid rewriting/loading works that are
            # already attached
            existing_works = work.member_ids
            attributes_collection.each do |attributes|
              next if attributes['id'].blank?
              if existing_works.include?(attributes['id'])
                remove(work: work, id: attributes['id']) if has_destroy_flag?(attributes)
              else
                add(work: work, ability: ability, id: attributes['id'])
              end
            end
          end

          # Adds the item to the ordered members so that it displays in the items
          # along side the FileSets on the show page
          def add(work:, ability:, id:)
            member = ActiveFedora::Base.find(id)
            return unless ability.can?(:edit, member)
            work.ordered_members << member
          end

          # Remove the object from the members set and the ordered members list
          def remove(work:, id:)
            member = ActiveFedora::Base.find(id)
            work.ordered_members.delete(member)
            work.members.delete(member)
          end

          # Determines if a hash contains a truthy _destroy key.
          # rubocop:disable Naming/PredicateName
          def has_destroy_flag?(hash)
            ActiveFedora::Type::Boolean.new.cast(hash['_destroy'])
          end
      end
    end
  end
end
