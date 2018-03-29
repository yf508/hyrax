require "dry/transaction"

module Hyrax
  module Transactions
    class UpdateWorkTransaction
      include Dry::Transaction(container: Hyrax::Transactions::Container)

      # TODO Put steps in the correct order
      step :validate_optimistic_lock, with: 'update_operations.validate_optimistic_lock'
      step :ensure_admin_set, with: 'operations.ensure_admin_set'
      step :assign_nested_attributes, with: 'operations.assign_nested_attributes'
      step :add_to_works, with: 'operations.add_to_works'
      step :attach_remote_files, with: 'operations.attach_remote_files'
      step :validate_files, with: 'operations.validate_files'
      step :apply_lease, with: 'operations.apply_lease'
      step :apply_embargo, with: 'operations.apply_embargo'
      step :apply_visibility, with: 'operations.apply_visibility'
      step :cleanup_featured_works_when_private, with: 'update_operations.cleanup_featured_works_when_private'
      step :save_work, with: 'operations.save_work'
      step :attach_files, with: 'operations.attach_files'
      step :attach_members, with: 'update_operations.attach_members'
      step :apply_order, with: 'update_operations.apply_order'
    end
  end
end
