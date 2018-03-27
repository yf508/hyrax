require "dry/transaction"

module Hyrax
  module Transactions
    class DeleteWorkTransaction
      include Dry::Transaction(container: Hyrax::Transactions::Container)

      step :cleanup_file_sets, with: 'operations.cleanup_file_sets'
    end
  end
end
