# frozen_string_literal: true
module Hyrax
  module Actors
    ##
    # An actor which short circuits the rest of the stack for `#destory`,
    # replacing with a call to `Hyrax::Transactions::DestroyWork`.
    class DryDestroyActor < AbstractActor
      ##
      # @!attribute [rw] error_handler
      #   @return [#call]
      # @!attribute [rw] transaction
      #   @return [Dry::Transaction]
      attr_accessor :error_handler, :transaction

      ##
      # @param [#call]            error_handler
      # @param [Dry::Transaction] transaction
      #
      # @see AbstractActor.initialize
      def initialize(*args,
                     error_handler: ->(err) {},
                     transaction:   Hyrax::Transactions::DestroyWork.new)
        self.error_handler = error_handler
        self.transaction   = transaction

        super *args
      end

      ##
      # Drops the remaining Actors in favor of the `DestroyWork` transaction.
      def destroy(env)
        transaction
          .call(env.curation_concern)
          .or { |err| error_handler.call(err); false }
      end
    end
  end
end
