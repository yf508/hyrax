# frozen_string_literals: true

module Hyrax
  class WorkChangeSetPersister < ChangeSetPersister
    before_delete :cleanup_file_sets
    before_save :ensure_admin_set

    # Deletes all file_sets that are members of the resource in the supplied change_set
    # @param [Hyrax::WorkChangeSet] the change_set that contains the resource whose member file_sets you wish to delete
    def cleanup_file_sets(change_set:)
      file_set_members = metadata_adapter.query_service.find_members(resource: change_set.resource, model: ::FileSet)
      change_sets = file_set_members.map do |file_set|
        Hyrax::FileSetChangeSet.new(file_set)
      end
      FileChangeSetPersister.new(metadata_adapter: Valkyrie::MetadataAdapter.find(:indexing_persister), storage_adapter: Valkyrie.config.storage_adapter).delete_all(change_sets: change_sets)
    end

    def ensure_admin_set(change_set:)
      # If admin_set id in the change_set, validate, blowup if bad id
      # If no admin_set id in change_set AND resource has no admin_set, put in default_admin
      #binding.pry
      if change_set.resource.admin_set_id.empty? && !change_set.changed?(:admin_set_id)
        binding.pry
        change_set.admin_set_id = AdminSet.find_or_create_default_admin_set_id
      end

      if change_set.changed?(:admin_set_id)
        # TODO raise argument error if new_admin_set_id doesn't point to a valid admin_set
        Hyrax::PermissionTemplate.find_by(admin_set_id: change_set.attributes.admin_set_id.to_s) || create_permission_template!(admin_set_id: admin_set_id)
      end
    end
  end
end
