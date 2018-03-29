require 'rails_helper'

RSpec.describe Hyrax::Transactions::Steps::RemoveFromCollectionsStep do
  subject(:step) { described_class.new }
  let(:work)     { FactoryBot.build(:generic_work) }

  it 'returns success' do
    expect(step.call(work)).to be_success
  end

  context 'with collections' do
    let!(:collections) { FactoryBot.create_list(:collection_lw, 2, members: [work]) }
    let(:work)         { FactoryBot.create(:generic_work) }

    it 'removes the work from the collections' do
      expect { step.call(work) }
        .to change { work.in_collections }
        .to be_empty
    end

    context 'and the collection is not found' do
      before { allow(Collection).to receive(:find).and_return(nil) }

      it 'is a failure' do
        expect(step.call(work)).to be_failure
      end
    end
  end
end
