require "dry/transaction/operation"

module Hyrax
  module Transactions
    module Steps
      class CleanupTrophiesStep
        include Dry::Transaction::Operation

        def call(work)
          Trophy.where(work_id: work.id).destroy_all
          Success(work)
        end
      end
    end
  end
end
