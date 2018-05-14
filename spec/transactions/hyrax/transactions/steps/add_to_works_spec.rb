# frozen_string_literal: true
RSpec.describe Hyrax::Transactions::Steps::AddToWorks do
  subject(:step) { described_class.new }
  let(:work)     { create(:generic_work) }

  it 'is a success' do
    expect(step.call(work)).to be_success
  end

  context 'when work is not persisted' do
    let(:work) { build(:generic_work) }

    it 'is a failure' do
      expect(step.call(work)).to be_failure
    end
  end

  context 'when adding to missing work ids' do
    let(:other_work_ids) { [create(:generic_work).id, 'not_a_real_id'] }

    it 'is a failure' do
      expect(step.call(work, work_ids: other_work_ids)).to be_failure
    end
  end

  context 'when adding to existing work ids' do
    let(:other_works)    { create_list(:generic_work, 2) }
    let(:other_work_ids) { other_works.map(&:id) }

    it 'is a success' do
      expect(step.call(work, work_ids: other_work_ids)).to be_success
    end

    it 'adds the work to the others' do
      expect { step.call(work, work_ids: other_work_ids) }
        .to change { work.member_of.map(&:id) }
        .from(be_empty)
        .to(other_work_ids)
    end
  end
end
