require 'rails_helper'

RSpec.describe Hyrax::Transactions::CreateWorkTransaction do
  subject(:transaction) { described_class.new }
  let(:work)            { build(:generic_work) }

  describe '#call' do
    it 'is a success' do
      expect(transaction.call(work)).to be_success
    end

    it 'saves the work' do
      expect { transaction.call(work) }
        .to change { work.persisted? }
        .to true
    end

    it 'sets the modified time using Hyrax::TimeService' do
      xmas = DateTime.parse('2018-12-25 11:30').iso8601

      allow(Hyrax::TimeService).to receive(:time_in_utc).and_return(xmas)

      expect { transaction.call(work) }.to change { work.date_modified }.to xmas
    end

    it 'sets the uploaded time using Hyrax::TimeService' do
      xmas = DateTime.parse('2018-12-25 11:30').iso8601

      allow(Hyrax::TimeService).to receive(:time_in_utc).and_return(xmas)

      expect { transaction.call(work) }.to change { work.date_uploaded }.to xmas
    end
  end
end
