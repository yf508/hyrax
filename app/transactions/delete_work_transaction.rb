module Hyrax
  module Transactions
    class DeleteWorkTransaction
      include Dry::Transaction(container: Container)

      step :cleanup_file_sets, with: 'operations.cleaup_file_sets'
    end
  end
end
