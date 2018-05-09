module Hyrax
  module Transactions
    class CreateWork
      include Dry::Transaction(container: Hyrax::Transactions::Container)

      step :apply_attributes,           with: 'work.apply_attributes'
      step :set_default_admin_set,      with: 'work.set_default_admin_set'
      step :ensure_admin_set,           with: 'work.ensure_admin_set'
      step :apply_permission_template,  with: 'work.apply_permission_template'
      step :set_modified_date,          with: 'work.set_modified_date'
      step :set_uploaded_date,          with: 'work.set_uploaded_date'
      step :save_work,                  with: 'work.save_work'
    end
  end
end
