require "dry/transaction"

module Hyrax
  module Transactions
    class DeleteWorkTransaction
      include Dry::Transaction(container: Hyrax::Transactions::Container)

      step :cleanup_file_sets, with: 'delete_operations.cleanup_file_sets'
      step :delete_work, with: 'delete_operations.delete_work'
    end
  end
end
