require "dry/transaction/operation"

module Hyrax
  module Transactions
    module Steps
      class DeleteWorkStep
        include Dry::Transaction::Operation

        def call(work)
          return Failure(:not_created) unless work.persisted?
          return Failure(:already_destroyed) if work.destroyed?

          work.destroy
          Success(work)
        end
      end
    end
  end
end
