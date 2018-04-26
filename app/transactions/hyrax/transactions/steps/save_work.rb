module Hyrax
  module Transactions
    module Steps
      class SaveWork
        include Dry::Transaction::Operation

        def call(work)
          work.save ? Success(work) : Failure(work.errors)
        end
      end
    end
  end
end
