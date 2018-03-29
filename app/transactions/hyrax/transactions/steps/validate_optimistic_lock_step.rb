require "dry/transaction/operation"

module Hyrax
  module Transactions
    module Steps
      class ValidateOptimisticLockStep
        include Dry::Transaction::Operation

        class_attribute :version_field
        self.version_field = 'version'

        # @return returns Success if the lock is missing or
        #                   if it matches the current object version.
        def call(env)
          work = env[:work]
          version = env[:attributes].delete(version_field)
          return Success(env) if version.blank? || version == work.etag
          work.errors.add(:base, :conflict)
          Failure(:conflict)
        end

        private

          # Removes the version attribute
          def version_attribute(attributes)
            attributes.delete(version_field)
          end
      end
    end
  end
end
