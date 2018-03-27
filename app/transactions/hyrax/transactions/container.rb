module Hyrax
  module Transactions
    class Container
      extend Dry::Container::Mixin

      namespace "operations" do |ops|
        ops.register "cleanup_file_sets" do
          Steps::CleanupFileSetsStep.new
        end
      end
    end
  end
end
