require "dry/transaction/operation"

module Hyrax
  module Transactions
    module Steps
      class InitializeWorkflowStep
        include Dry::Transaction::Operation

        class_attribute :workflow_factory
        self.workflow_factory = ::Hyrax::Workflow::WorkflowFactory

        def call(env)
          workflow_factory.create(env[:work], env[:attributes], env[:ability].current_user)
          Success(env)
        end
      end
    end
  end
end
