# frozen_string_literal: true
module Hyrax
  module Transactions
    module Steps
      class SetDepositor
        include Dry::Transaction::Operation

        def call(work, depositor: nil)
          work.depositor = depositor.user_key if depositor

          Success(work)
        end
      end
    end
  end
end
