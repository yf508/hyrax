# frozen_string_literal: true
module Hyrax
  module Transactions
    module Steps
      class ApplyPermissionTemplate
        include Dry::Transaction::Operation

        def call(work)
          return Failure(:missing_permission) unless
            (template = work&.admin_set&.permission_template)

          Hyrax::PermissionTemplateApplicator.apply(template).to(model: work)

          Success(work)
        rescue ActiveRecord::RecordNotFound => err
          Failure(err)
        end
      end
    end
  end
end
