module Hyrax
  module Transactions
    class Container
      extend Dry::Container::Mixin

      namespace "delete_operations" do |ops|
        ops.register "cleanup_file_sets" do
          Steps::CleanupFileSetsStep.new
        end

        ops.register "delete_work" do
          Steps::DeleteWorkStep.new
        end
      end
    end
  end
end
