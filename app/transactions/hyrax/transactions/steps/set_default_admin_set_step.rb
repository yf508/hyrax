require "dry/transaction/operation"

module Hyrax
  module Transactions
    module Steps
      class SetDefaultAdminSetStep
        include Dry::Transaction::Operation

        def call(work)
          work.admin_set_id ||=
            AdminSet.find_or_create_default_admin_set_id

          Success(work)
        end
      end
    end
  end
end
