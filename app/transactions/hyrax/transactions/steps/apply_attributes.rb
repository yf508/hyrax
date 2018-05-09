# frozen_string_literal: true
module Hyrax
  module Transactions
    module Steps
      class ApplyAttributes
        include Dry::Transaction::Operation

        def call(work, attributes: {})
          (work.attributes = attributes) unless attributes.empty?

          Success(work)

        rescue ActiveFedora::UnknownAttributeError => err
          Failure(err)
        end
      end
    end
  end
end
