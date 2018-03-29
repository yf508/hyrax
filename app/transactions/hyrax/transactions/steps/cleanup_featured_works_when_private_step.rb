require "dry/transaction/operation"

module Hyrax
  module Transactions
    module Steps
      class CleanupFeaturedWorksWhenPrivateStep
        include Dry::Transaction::Operation

        def call(env)
          work = env[:work]
          return Success(env) unless work.private?
          FeaturedWork.where(work_id: work.id).destroy_all
          return Failure(:featured_works_remain) if FeaturedWork.where(work_id: work.id).any?
          Success(env)
        end
      end
    end
  end
end
