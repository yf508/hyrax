require 'rails_helper'

RSpec.describe Hyrax::Transactions::Steps::DeleteWorkStep do
  subject(:step) { described_class.new }
  let(:work)     { FactoryBot.build(:generic_work) }

  it 'is failure' do
    expect(step.call(work)).to be_failure
  end

  describe '#call' do
    context 'when the work exists' do
      let(:work) { FactoryBot.create(:generic_work) }

      it 'destroys the work' do
        expect { step.call(work) }.to change { work.destroyed? }.to true
      end

      it 'is successful' do
        expect(step.call(work)).to be_success
      end

      context 'and destroyed' do
        before { work.destroy }

        it 'is failure' do
          expect(step.call(work)).to be_failure
        end
      end
    end
  end
end
