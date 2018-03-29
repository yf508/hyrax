require "dry/transaction/operation"

module Hyrax
  module Transactions
    module Steps
      class AddCreationDataStep
        include Dry::Transaction::Operation

        def call(env)
          work = env[:work]
          work.depositor = env[:ability].current_user
          work.date_uploaded = TimeService.time_in_utc
          Success(env)
        end
      end
    end
  end
end
