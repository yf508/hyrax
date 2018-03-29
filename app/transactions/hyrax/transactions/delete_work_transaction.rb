require "dry/transaction"

module Hyrax
  module Transactions
    class DeleteWorkTransaction
      include Dry::Transaction(container: Hyrax::Transactions::Container)

      step :cleanup_file_sets, with: 'delete_operations.cleanup_file_sets'
      step :cleanup_trophies, with: 'delete_operations.cleanup_trophies'
      step :cleanup_featured_works, with: 'delete_operations.cleanup_featured_works'
      step :remove_from_colections, with: 'delete_operations.remove_from_colections'
      step :delete_work, with: 'delete_operations.delete_work'
    end
  end
end
