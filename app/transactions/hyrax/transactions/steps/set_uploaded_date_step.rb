require "dry/transaction/operation"

module Hyrax
  module Transactions
    module Steps
      class SetUploadedDateStep
        include Dry::Transaction::Operation

        def call(work)
          work.date_uploaded =
            work.date_modified || Hyrax::TimeService.time_in_utc

          Success(work)
        end
      end
    end
  end
end
