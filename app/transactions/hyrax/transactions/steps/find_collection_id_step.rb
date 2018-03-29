require "dry/transaction/operation"

module Hyrax
  module Transactions
    module Steps
      class FindCollectionIdStep
        include Dry::Transaction::Operation

        def call(env)
          extract_collection_id(env[:attributes])
          Success(env)
        end

        private

          # Extact a singleton collection id from the collection attributes and save it in env.  Later in the actor stack,
          # in apply_permission_template_actor.rb, `env.attributes[:collection_id]` will be used to apply the
          # permissions of the collection to the created work.  With one and only one collection, the work is seen as
          # being created directly in that collection.  The permissions will not be applied to the work if the collection
          # type is configured not to allow that or if the work is being created in more than one collection.
          #
          # @param attributes [Hash]
          #
          # Given an array of collection_attributes when it is size:
          # * 0 do not set `env.attributes[:collection_id]`
          # * 1 set `env.attributes[:collection_id]` to the one and only one collection
          # * 2+ do not set `env.attributes[:collection_id]`
          #
          # NOTE: Only called from create.  All collections are being added as parents of a work.  None are being removed.
          def extract_collection_id(attributes)
            attributes_collection =
              attributes.fetch(:member_of_collections_attributes) { nil }

            if attributes_collection
              # Determine if the work is being created in one and only one collection.
              return unless attributes_collection && attributes_collection.size == 1

              # Extract the collection id from attributes_collection,
              collection_id = attributes_collection.first.second['id']
            else
              collection_ids = attributes.fetch(:member_of_collection_ids) { [] }
              return unless collection_ids.size == 1
              collection_id = collection_ids.first
            end

            # Do not apply permissions to work if collection type is configured not to
            collection = ::Collection.find(collection_id)
            return unless collection.share_applies_to_new_works?

            # Save the collection id in env for use in apply_permission_template_actor
            attributes[:collection_id] = collection_id
          end
      end
    end
  end
end
