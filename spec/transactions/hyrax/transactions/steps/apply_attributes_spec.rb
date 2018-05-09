# frozen_string_literal: true
RSpec.describe Hyrax::Transactions::Steps::ApplyAttributes do
  subject(:step) { described_class.new }
  let(:work)     { build(:generic_work) }

  describe '#call' do
    context 'with no attributes' do
      let(:work) { build(:generic_work, creator: ['moomin papa']) }

      it 'leaves the existing attributes in place' do
        expect { step.call(work) }.not_to change { work.attributes }
      end

      it 'is a success' do
        expect(step.call(work)).to be_success
      end
    end

    context 'with valid attributes' do
      let(:attributes) do
        attributes_for(:generic_work,
                       creator: ['moomin papa'],
                       title:   ['Comet in Moominland'])
      end

      it 'applies the attributes' do
        step.call(work, attributes: attributes)

        expect(work).to have_attributes attributes
      end
    end

    context 'with missing attributes' do
      let(:attributes) { attributes_for(:generic_work, not_real: :very_fake) }

      it 'is a failure' do
        expect(step.call(work, attributes: attributes)).to be_failure
      end

      it 'leaves attributes unchanged' do
        expect { step.call(work, attributes: attributes) }
          .not_to change { work.attributes }
      end
    end
  end
end
