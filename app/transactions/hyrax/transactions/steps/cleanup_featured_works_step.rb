require "dry/transaction/operation"

module Hyrax
  module Transactions
    module Steps
      class CleanupFeaturedWorksStep
        include Dry::Transaction::Operation

        def call(work)
          FeaturedWork.where(work_id: work.id).destroy_all
          return Failure(:featured_works_remain) if FeaturedWork.where(work_id: work.id).any?
          Success(work)
        end
      end
    end
  end
end
