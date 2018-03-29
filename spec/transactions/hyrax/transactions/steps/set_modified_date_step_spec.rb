require 'rails_helper'

RSpec.describe Hyrax::Transactions::Steps::SetModifiedDateStep do
  subject(:step) { described_class.new }
  let(:work)     { build(:generic_work) }

  describe '#call' do
    let(:xmas) { DateTime.parse('2018-12-25 11:30').iso8601 }

    before do
      allow(Hyrax::TimeService).to receive(:time_in_utc).and_return(xmas)
    end

    it 'is a success' do
      expect(step.call(work)).to be_success
    end

    it 'sets the modified date' do
      expect { step.call(work) }.to change { work.date_modified }.to xmas
    end

    context 'when the modified date already exists' do
      let(:xmas_past) { DateTime.parse('2009-12-25 11:30').iso8601 }
      let(:work)      { build(:generic_work, date_modified: xmas_past) }

      it 'overwrites the modified date' do
        expect { step.call(work) }
          .to change { work.date_modified }
          .from(xmas_past)
          .to xmas
      end
    end
  end
end
