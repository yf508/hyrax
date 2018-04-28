# frozen_string_literal: true
RSpec.describe Hyrax::Transactions::Steps::DestroyFileSets do
  subject(:step) { described_class.new }
  let(:work)     { build(:generic_work) }

  it 'is a success' do
    expect(step.call(work)).to be_success
  end

  context 'with file sets' do
    let(:file_sets) { work.file_sets }
    let(:work)      { create(:work_with_files) }

    it 'destroy file sets in work' do
      expect { step.call(work) }
        .to change { file_sets.any?(&:persisted?) }
        .to false
    end
  end
end
