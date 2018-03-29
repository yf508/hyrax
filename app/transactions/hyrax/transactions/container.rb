module Hyrax
  module Transactions
    class Container
      extend Dry::Container::Mixin

      namespace "operations" do |ops|
        ops.register "add_to_works" do
          Steps::AddToWorksStep.new
        end

        ops.register "save_work" do
          Steps::SaveWorkStep.new
        end

        ops.register "set_modified_date" do
          Steps::SetModifiedDateStep.new
        end

        ops.register "assign_nested_attributes" do
          Steps::AssignNestedAttributesStep.new
        end

        ops.register "attach_files" do
          Steps::AttachFilesStep.new
        end

        ops.register "attach_remote_files" do
          Steps::AttachRemoteFilesStep.new
        end

        ops.register "validate_files" do
          Steps::ValidateFilesStep.new
        end

        ops.register "ensure_admin_set" do
          Steps::EnsureAdminSetStep.new
        end

        ops.register "set_default_admin_set" do
          Steps::SetDefaultAdminSetStep.new
        end

        ops.register "apply_lease" do
          Steps::ApplyLeaseStep.new
        end

        ops.register "apply_embargo" do
          Steps::ApplyEmbargoStep.new
        end

        ops.register "apply_visibility" do
          Steps::ApplyVisibilityStep.new
        end
      end

      namespace "create_operations" do |ops|
        ops.register "add_collection_participants" do
          Steps::AddCollectionParticipants.new
        end

        ops.register "add_creation_data" do
          Steps::AddCreationDataStep.new
        end

        ops.register "find_collection_id" do
          Steps::FindCollectionIdStep.new
        end

        ops.register "initialize_workflow" do
          Steps::InitializeWorkflowStep.new
        end

        ops.register "set_uploaded_date" do
          Steps::SetUploadedDateStep.new
        end

        ops.register "transfer_request" do
          Steps::TransferRequestStep.new
        end
      end

      namespace "update_operations" do |ops|
        ops.register "validate_optimistic_lock" do
          Steps::ValidateOptimisticLockStep.new
        end

        ops.register "cleanup_featured_works_when_private" do
          Steps::CleanupFeaturedWorksWhenPrivateStep.new
        end

        ops.register "attach_members" do
          Steps::AttachMembersStep.new
        end

        ops.register "apply_order" do
          Steps::ApplyOrderStep.new
        end
      end

      namespace "delete_operations" do |ops|
        ops.register "cleanup_file_sets" do
          Steps::CleanupFileSetsStep.new
        end

        ops.register "cleanup_featured_works" do
          Steps::CleanupFeaturedWorksStep.new
        end

        ops.register "delete_work" do
          Steps::DeleteWorkStep.new
        end

        ops.register "remove_from_colections" do
          Steps::RemoveFromCollectionsStep.new
        end

        ops.register "cleanup_trophies" do
          Steps::CleanupTrophiesStep.new
        end
      end
    end
  end
end
