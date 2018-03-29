require 'rails_helper'

RSpec.describe Hyrax::Transactions::Steps::SetDefaultAdminSetStep do
  subject(:step) { described_class.new }
  let(:work)     { create(:generic_work) }

  describe '#call' do
    it 'is success' do
      expect(step.call(work)).to be_success
    end

    context 'with no admin set' do
      it 'sets the default admin set' do
        expect { step.call(work) }
          .to change { work.admin_set&.id }
          .to AdminSet.find_or_create_default_admin_set_id
      end
    end

    context 'with an admin set' do
      let(:admin_set) { create(:admin_set) }
      let(:work)      { build(:generic_work, admin_set_id: admin_set.id) }

      it 'retains the proveded the admin set' do
        expect { step.call(work) }
          .not_to change { work.admin_set&.id }
          .from admin_set.id
      end
    end
  end
end
