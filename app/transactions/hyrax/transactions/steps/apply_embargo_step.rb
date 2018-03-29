embargorequire "dry/transaction/operation"

module Hyrax
  module Transactions
    module Steps
      class ApplyEmbargoStep
        include Dry::Transaction::Operation

        def call(env)
          work = env[:work]
          attributes = env[:attributes]
          template = PermissionTemplate.find_by!(source_id: attributes[:admin_set_id]) if attributes[:admin_set_id].present?
          return Failure(:invalid_release_type) unless validate_release_type(work: work, visibility: attributes[:visibility], template: template)
          return Failure(:invalid_embargo) unless validate_embargo(work: work, attributes: attributes, template: template)
          work.apply_embargo(embargo_params(attributes))
          return Failure(:embargo_not_created) unless work.embargo
          work.embargo.save
          Success(env)
        end

        private

          # Validate the selected release settings against template, checking for when embargoes/leases are not allowed
          def validate_release_type(work:, visibility:, template:)
            # It's valid as long as embargo is not specified when a template requires no release delays
            return true unless wants_embargo?(visiblity) && template.present? && template.release_no_delay?

            work.errors.add(:visibility, 'Visibility specified does not match permission template "no release delay" requirement for selected AdminSet.')
            false
          end

          # When specified, validate embargo is a future date that complies with AdminSet template requirements (if any)
          def validate_embargo(work:, attributes:, template:)
            return true unless wants_embargo?(visibility)

            embargo_release_date = parse_date(attributes[:embargo_release_date])

            # When embargo required, date must be in future AND matches any template requirements
            return true if valid_future_date?(work: work, date: embargo_release_date) &&
                           valid_template_embargo_date?(work: work, date: embargo_release_date, template: template) &&
                           valid_template_visibility_after_embargo?(work: work, visibility_after_embargo: attributes[:visibility_after_embargo], template: template)

            work.errors.add(:visibility, 'When setting visibility to "embargo" you must also specify embargo release date.') if embargo_release_date.blank?
            false
          end

          def wants_embargo?(visibility)
            visibility == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO
          end

          # Parse date from string. Returns nil if date_string is not a valid date
          def parse_date(date_string)
            datetime = Time.zone.parse(date_string) if date_string.present?
            return datetime.to_date unless datetime.nil?
            nil
          end

          # Validate an date attribute is in the future
          def valid_future_date?(work:, date:, attribute_name: :embargo_release_date)
            return true if date.present? && date.future?

            work.errors.add(attribute_name, "Must be a future date.")
            false
          end

          # Validate an embargo date against permission template restrictions
          def valid_template_embargo_date?(work:, date:, template:)
            return true if template.blank?

            # Validate against template's release_date requirements
            return true if template.valid_release_date?(date)

            work.errors.add(:embargo_release_date, "Release date specified does not match permission template release requirements for selected AdminSet.")
            false
          end

          # Validate the post-embargo visibility against permission template requirements (if any)
          def valid_template_visibility_after_embargo?(work:, visibility_after_embargo:, template:)
            # Validate against template's visibility requirements
            return true if validate_template_visibility(visibility_after_embargo, template)

            work.errors.add(:visibility_after_embargo, "Visibility after embargo does not match permission template visibility requirements for selected AdminSet.")
            false
          end

          # Validate that a given visibility value satisfies template requirements
          def validate_template_visibility(visibility, template)
            return true if template.blank?

            template.valid_visibility?(visibility)
          end

          def valid_embargo?(attributes)
            attributes[:embargo_release_date].present?
          end

          def embargo_params(attributes)
            [:embargo_release_date,
             :visibility_during_embargo,
             :visibility_after_embargo].map { |key| attributes[key] }
          end
      end
    end
  end
end
