# frozen_string_literal: true
module Hyrax
  module Transactions
    module Steps
      class DestroyWork
        include Dry::Transaction::Operation

        def call(work)
          work.destroy! ? Success(work) : Failure(work)
        rescue => err
          Failure(err)
        end
      end
    end
  end
end
