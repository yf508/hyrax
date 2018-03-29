require "dry/transaction/operation"

module Hyrax
  module Transactions
    module Steps
      class SaveWorkStep
        include Dry::Transaction::Operation

        def call(work)
          work.save ? Success(work) : Failure(:not_saved)
        end
      end
    end
  end
end
