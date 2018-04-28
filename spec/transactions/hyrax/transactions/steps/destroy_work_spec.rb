# frozen_string_literal: true
RSpec.describe Hyrax::Transactions::Steps::DestroyWork do
  subject(:step) { described_class.new }
  let(:work)     { build(:generic_work) }

  it 'is a success' do
    expect(step.call(work)).to be_success
  end

  context 'with an existing work' do
    let(:work) { create(:generic_work) }

    it 'destroys the work' do
      expect { step.call(work) }
        .to change { work.destroyed? }
        .to true
    end

    context 'when destroy fails for unknown reasons' do
      let(:message) { 'moomin' }

      before { allow(work).to receive(:destroy).and_raise(message) }

      it 'is a failure' do
        expect(step.call(work).failure.message).to eq message
      end
    end
  end
end
