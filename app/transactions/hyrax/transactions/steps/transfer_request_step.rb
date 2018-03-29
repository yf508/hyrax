require "dry/transaction/operation"

module Hyrax
  module Transactions
    module Steps
      class TransferRequestStep
        include Dry::Transaction::Operation

        def call(env)
          proxy = env[:work].on_behalf_of
          return Success(env) if proxy.blank?
          ContentDepositorChangeEventJob.perform_later(env[:work],
                                                       ::User.find_by_user_key(proxy))
          Success(env)
        end
      end
    end
  end
end
