RSpec.describe Hyrax::Transactions::DeleteWorkTransaction do
  describe "#call" do
    subject { described_class.new }

    let(:work) { create(:work_with_one_file) }

    it 'removes all file sets' do
      expect { subject.call(work) }.to change { FileSet.count }.by(-1)
    end
  end
end
