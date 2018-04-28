# frozen_string_literal: true
RSpec.describe Hyrax::Transactions::Steps::CleanupTrophies do
  subject(:step) { described_class.new }
  let(:work)     { build(:generic_work, id: 'work_id') }

  it 'is a success' do
    expect(step.call(work)).to be_success
  end

  context 'with trophies' do
    let!(:trophies) do
      [FeaturedWork.create(work_id: work.id),
       FeaturedWork.create(work_id: work.id)]
    end

    it 'removes featured work entries for the work' do
      expect { step.call(work) }
        .to change { FeaturedWork.where(work_id: work.id).any? }
        .to false
    end

    it 'is a success' do
      expect(step.call(work)).to be_success
    end
  end
end
