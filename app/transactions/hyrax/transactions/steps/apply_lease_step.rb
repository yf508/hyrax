require "dry/transaction/operation"

module Hyrax
  module Transactions
    module Steps
      class ApplyLeaseStep
        include Dry::Transaction::Operation

        def call(env)
          work = env[:work]
          attributes = env[:attributes]
          template = PermissionTemplate.find_by!(source_id: attributes[:admin_set_id]) if attributes[:admin_set_id].present?
          return Failure(:invalid_lease) unless validate_lease(work: work, attributes: attributes, template: template)
          work.apply_lease(lease_params(attributes))
          return Failure(:lease_not_created) unless work.lease
          work.lease.save
          Success(env)
        end

        private

          # Validate that a lease is allowed by AdminSet's PermissionTemplate
          def validate_lease(work:, attributes:, template:)
            return true unless wants_lease?(attributes[:visibility])

            # Leases are only allowable if a template doesn't require a release period or have any specific visibility requirement
            # (Note: permission template release/visibility options do not support leases)
            unless template.present? && (template.release_period.present? || template.visibility.present?)
              return true if valid_lease?(attributes)
              work.errors.add(:visibility, 'When setting visibility to "lease" you must also specify lease expiration date.')
              return false
            end

            work.errors.add(:visibility, 'Lease option is not allowed by permission template for selected AdminSet.')
            false
          end

          def wants_lease?(visibility)
            visibility == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_LEASE
          end

          def valid_lease?(attributes)
            attributes[:lease_expiration_date].present?
          end

          def lease_params(attributes)
            [:lease_expiration_date,
             :visibility_during_lease,
             :visibility_after_lease].map { |key| attributes[key] }
          end
      end
    end
  end
end
