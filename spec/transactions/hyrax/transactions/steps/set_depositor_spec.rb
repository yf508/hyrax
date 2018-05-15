# frozen_string_literal: true
RSpec.describe Hyrax::Transactions::Steps::SetDepositor do
  subject(:step) { described_class.new }
  let(:work)     { GenericWork.new }

  it 'is a success' do
    expect(step.call(work)).to be_success
  end

  it 'leaves the depositor unset' do
    expect { step.call(work) }
      .not_to change { work.depositor }
      .from nil
  end

  context 'with a depositor' do
    let(:depositor) { create(:admin) }

    it 'sets the depositor' do
      expect { step.call(work, depositor: depositor) }
        .to change { work.depositor }
        .to depositor.user_key
    end

    it 'overrides existing depositor' do
      work.depositor = create(:user).user_key

      expect { step.call(work, depositor: depositor) }
        .to change { work.depositor }
        .to depositor.user_key
    end
  end
end
