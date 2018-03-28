require "dry/transaction/operation"

module Hyrax
  module Transactions
    module Steps
      class CleanupTrophiesStep
        include Dry::Transaction::Operation

        def call(work)
          Trophy.where(work_id: work.id).destroy_all
          return Failure(:trophies_remain) if Trophy.where(work_id: work.id).any?
          Success(work)
        end
      end
    end
  end
end
