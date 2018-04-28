# frozen_string_literal: true
module Hyrax
  module Transactions
    module Steps
      class DestroyFileSets
        include Dry::Transaction::Operation

        def call(work)
          work.file_sets.each(&:destroy)

          Success(work)
        end
      end
    end
  end
end
