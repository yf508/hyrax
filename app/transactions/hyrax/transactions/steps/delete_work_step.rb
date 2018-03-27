require "dry/transaction/operation"

module Hyrax
  module Transactions
    module Steps
      class DeleteWorkStep
        include Dry::Transaction::Operation

        def call(work)
          work.destroy
          Success(work)
        end
      end
    end
  end
end
