require "dry/transaction/operation"

module Hyrax
  module Transactions
    module Steps
      class EnsureAdminSetStep
        include Dry::Transaction::Operation

        def call(env)
          ensure_admin_set_attribute!(env[:attributes])
          Success(env) if env[:attributes].has_key? :admin_set_id
          Failure(:no_admin_set_id)
        end

        private

          def ensure_admin_set_attribute!(attributes)
            if admin_set_id.present?
              ensure_permission_template!(admin_set_id: admin_set_id)
            else
              attributes[:admin_set_id] = default_admin_set_id
            end
          end

          def ensure_permission_template!(admin_set_id:)
            Hyrax::PermissionTemplate.find_by(source_id: admin_set_id) || create_permission_template!(source_id: admin_set_id)
          end

          def default_admin_set_id
            AdminSet.find_or_create_default_admin_set_id
          end

          # Creates a Hyrax::PermissionTemplate for the given AdminSet
          def create_permission_template!(source_id:)
            Hyrax::PermissionTemplate.create!(source_id: source_id)
          end
      end
    end
  end
end
