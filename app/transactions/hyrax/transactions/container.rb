module Hyrax
  module Transactions
    class Container
      extend Dry::Container::Mixin

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
