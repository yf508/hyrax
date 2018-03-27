require "dry/transaction/operation"

module Hyrax
  module Transactions
    module Steps
      class RemoveFromCollectionsStep
        include Dry::Transaction::Operation

        def call(work)
          work.in_collection_ids.each do |id|
            destination_collection = ::Collection.find(id)
            destination_collection.members.delete(work)
            destination_collection.update_index
          end
          Success(work)
        end
      end
    end
  end
end
