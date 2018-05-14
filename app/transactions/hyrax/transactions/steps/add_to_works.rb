# frozen_string_literal: true
module Hyrax
  module Transactions
    module Steps
      class AddToWorks
        include Dry::Transaction::Operation

        ##
        # @todo make this robust to failures of #save! calls on other works.
        #   Currently, we can fail on any given work, but have already added
        #   the new work to all the prior works. This is a carry over from actor
        #   stack behavior. In that stack, we would encounter this issue if any
        #   work didn't exist. Here, we fail only if the actual save call fails.
        #
        # @todo ensure correct abilities before saving?
        def call(work, work_ids: [])
          return Failure(:work_not_persisted) unless work.persisted?

          ActiveFedora::Base.find(work_ids).each do |other|
            other.ordered_members << work
            other.save!
          end

          Success(work)
        rescue ActiveFedora::ObjectNotFoundError => err
          Failure(err)
        end
      end
    end
  end
end
