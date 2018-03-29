require "dry/transaction/operation"

module Hyrax
  module Transactions
    module Steps
      class SaveWorkStep
        include Dry::Transaction::Operation

        def call(env)
          work = env[:work]
          work.attributes = prepare_attributes(env[:attributes])
          work.date_modified = TimeService.time_in_utc
          return Failure(:not_valid) unless work.valid?
          return Success(work) if work.save
          Failure(:not_saved)
        end

        private

          def prepare_attributes(attributes)
            force_multiple_attributes!(attributes)
            remove_blank_attributes!(attributes)
            attributes
          end

          # Cast any singular values from the form to multiple values for persistence
          # TODO this method could move to the work form.
          def force_multiple_attributes!(attributes)
            attributes[:license] = Array(attributes[:license]) if attributes.key? :license
            attributes[:rights_statement] = Array(attributes[:rights_statement]) if attributes.key? :rights_statement
          end

          # If any attributes are blank remove them
          # e.g.:
          #   self.attributes = { 'title' => ['first', 'second', ''] }
          #   remove_blank_attributes!
          #   self.attributes
          # => { 'title' => ['first', 'second'] }
          def remove_blank_attributes!(attributes)
            multivalued_form_attributes(attributes).each_with_object(attributes) do |(k, v), h|
              h[k] = v.instance_of?(Array) ? v.select(&:present?) : v
            end
          end

          # Return the hash of attributes that are multivalued and not uploaded files
          def multivalued_form_attributes(attributes)
            attributes.select { |_, v| v.respond_to?(:select) && !v.respond_to?(:read) }
          end
      end
    end
  end
end
