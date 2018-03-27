require "dry/transaction/operation"

module Hyrax
  module Transactions
    module Steps
      class CleanupFeaturedWorkStep
        include Dry::Transaction::Operation

        def call(work)
          FeaturedWork.where(work_id: work.id).destroy_all
          Success(work)
        end
      end
    end
  end
end
