# frozen_string_literal: true
RSpec.describe Hyrax::Transactions::DestroyWork do
  subject(:transaction) { described_class.new }
  let(:work)            { create(:generic_work) }

  describe '#call' do
    it 'is a success' do
      expect(transaction.call(work)).to be_success
    end

    it 'destroys the work' do
      expect { transaction.call(work) }
        .to change { work.persisted? }
        .from(true)
        .to false
    end

    context 'with file_sets' do
      let(:file_sets) { work.file_sets }
      let(:work)      { create(:work_with_files) }

      it 'destroy file sets in work' do
        expect { transaction.call(work) }
          .to change { file_sets.any?(&:persisted?) }
          .to false
      end
    end

    context 'with trophies' do
      let!(:trophies) do
        [Trophy.create(work_id: work.id), Trophy.create(work_id: work.id)]
      end

      it 'is a success' do
        expect(transaction.call(work)).to be_success
      end

      it 'removes trophies for the work' do
        expect { transaction.call(work) }
          .to change { Trophy.where(work_id: work.id).any? }
          .to false
      end
    end

    context 'when featured' do
      let!(:features) do
        [FeaturedWork.create(work_id: work.id),
         FeaturedWork.create(work_id: work.id)]
      end

      it 'is a success' do
        expect(transaction.call(work)).to be_success
      end

      it 'removes trophies for the work' do
        expect { transaction.call(work) }
          .to change { FeaturedWork.where(work_id: work.id).any? }
          .to false
      end
    end

    context 'with an unsaved work' do
      let(:work) { build(:generic_work) }

      it 'is a success' do
        expect(transaction.call(work)).to be_success
      end

      it 'leaves the work unpersisted' do
        expect { transaction.call(work) }
          .not_to change { work.persisted? }
          .from false
      end
    end
  end
end
