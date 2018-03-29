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

        ops.register "assign_nested_attributes" do
          Steps::AssignNestedAttributesStep.new
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
      end

      namespace "delete_operations" do |ops|
        ops.register "cleanup_file_sets" do
          Steps::CleanupFileSetsStep.new
        end

        ops.register "cleanup_featured_work" do
          Steps::CleanupFeaturedWorkStep.new
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
