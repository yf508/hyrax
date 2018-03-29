require "dry/transaction"

module Hyrax
  module Transactions
    class CreateWorkTransaction
      include Dry::Transaction(container: Hyrax::Transactions::Container)

      step :find_collection_id, with: 'create_operations.find_collection_id'
      step :assign_nested_attributes, with: 'operations.assign_nested_attributes'
      step :add_to_works, with: 'operations.add_to_works'
      step :add_collection_participants, with: 'create_operations.add_collection_participants'
      step :add_creation_data, with: 'create_operations.add_creation_data'
      step :save_work, with: 'operations.save_work'
    end
  end
end
