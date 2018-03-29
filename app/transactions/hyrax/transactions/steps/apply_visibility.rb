require "dry/transaction/operation"

module Hyrax
  module Transactions
    module Steps
      class ApplyVisibilityStep
        include Dry::Transaction::Operation

        def call(env)
          work = env[:work]
          visibility = env[:attributes][:visibility]
          admin_set_id = env[:attributes][:admin_set_id]
          template = PermissionTemplate.find_by!(source_id: admin_set_id) if admin_set_id
          return Failure(:invalid_visibility) unless validate_visibility(work: work, visibility: visibility, template: template)
          work.visibility = visibility if visibility
          Success(env)
        end

        private

          # Validate visibility complies with AdminSet template requirements
          def validate_visibility(work:, visibility:, template:)
            return true if visibility.blank?

            # Validate against template's visibility requirements
            return true if validate_template_visibility(visibility, template)

            work.errors.add(:visibility, 'Visibility specified does not match permission template visibility requirement for selected AdminSet.')
            false
          end

          # Validate that a given visibility value satisfies template requirements
          def validate_template_visibility(visibility, template)
            return true if template.blank?

            template.valid_visibility?(visibility)
          end
      end
    end
  end
end
