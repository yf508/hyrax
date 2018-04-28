# frozen_string_literal: true
module Hyrax
  module Transactions
    module Steps
      class CleanupTrophies
        include Dry::Transaction::Operation

        def call(work)
          Trophy.where(work_id: work.id).destroy_all

          Success(work)
        end
      end
    end
  end
end
