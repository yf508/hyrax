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
  end
end
