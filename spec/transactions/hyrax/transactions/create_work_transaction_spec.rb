require 'rails_helper'

RSpec.describe Hyrax::Transactions::CreateWorkTransaction do
  subject(:transaction) { described_class.new }
  let(:work)            { build(:generic_work, admin_set_id: admin_set.id) }
  let(:admin_set)       { create(:admin_set) }

  describe '#call' do
    let(:xmas) { DateTime.parse('2018-12-25 11:30').iso8601 }

    it 'is a success' do
      expect(transaction.call(work)).to be_success
    end

    it 'saves the work' do
      expect { transaction.call(work) }
        .to change { work.persisted? }
        .to true
    end

    it 'sets the modified time using Hyrax::TimeService' do
      allow(Hyrax::TimeService).to receive(:time_in_utc).and_return(xmas)

      expect { transaction.call(work) }.to change { work.date_modified }.to xmas
    end

    it 'sets the uploaded time using Hyrax::TimeService' do
      allow(Hyrax::TimeService).to receive(:time_in_utc).and_return(xmas)

      expect { transaction.call(work) }.to change { work.date_uploaded }.to xmas
    end

    it 'sets the provided admin set' do
      expect { transaction.call(work) }
        .not_to change { work.admin_set&.id }
        .from admin_set.id
    end

    it 'sets visibility to restricted by default' do
      expect { transaction.call(work) }
        .not_to change { work.visibility }
        .from Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    end

    context 'without an admin_set_id' do
      let(:work) { build(:generic_work) }

      it 'sets the default admin set' do
        expect { transaction.call(work) }
          .to change { work.admin_set&.id }
          .to AdminSet.find_or_create_default_admin_set_id
      end
    end

    context 'with public visibility' do
      let(:visibility) do
        Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      end

      let(:work) { build(:generic_work, visibility: visibility ) }

      it 'sets the default admin set' do
        expect { transaction.call(work) }
          .not_to change { work.visibility }
          .from visibility
      end
    end
  end
end
