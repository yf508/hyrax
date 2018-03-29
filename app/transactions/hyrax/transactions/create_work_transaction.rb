require "dry/transaction"

module Hyrax
  module Transactions
    class CreateWorkTransaction
      include Dry::Transaction(container: Hyrax::Transactions::Container)

      # TODO: Put steps in the correct order
      # step :find_collection_id, with: 'create_operations.find_collection_id'
      # step :ensure_admin_set, with: 'operations.ensure_admin_set'
      # step :assign_nested_attributes, with: 'operations.assign_nested_attributes'
      # step :add_to_works, with: 'operations.add_to_works'
      # step :add_collection_participants, with: 'create_operations.add_collection_participants'
      # step :add_creation_data, with: 'create_operations.add_creation_data'
      # step :attach_remote_files, with: 'operations.attach_remote_files'
      # step :validate_files, with: 'operations.validate_files'
      # step :apply_lease, with: 'operations.apply_lease'
      # step :apply_embargo, with: 'operations.apply_embargo'
      # step :apply_visibility, with: 'operations.apply_visibility'
      step :set_default_admin_set, with: 'operations.set_default_admin_set'
      step :ensure_admin_set,  with: 'operations.ensure_admin_set'
      step :set_modified_date, with: 'operations.set_modified_date'
      step :set_uploaded_date, with: 'create_operations.set_uploaded_date'
      step :save_work, with: 'operations.save_work'
      # step :attach_files, with: 'operations.attach_files'
      # step :initialize_workflow, with: 'create_operations.initialize_workflow'
      # step :transfer_request, with: 'create_operations.transfer_request'
    end
  end
end
