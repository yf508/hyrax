RSpec.describe Hyrax::Admin::CollectionTypesPresenter do
  let(:collection_types) do
    [create(:user_collection_type),
     create(:admin_set_collection_type),
     FactoryBot.create(:collection_type, title: 'Test Title 1'),
     FactoyBot.create(:collection_type, title: 'Test Title 2')]
  end

  subject { described_class.new(collection_types) }

  its(:english?) { is_expected.to be_truthy }
  its(:size) { is_expected.to eq(4) }
end
