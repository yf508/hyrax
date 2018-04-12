module Hyrax
  module Admin
    class CollectionTypesPresenter
      attr_reader :collection_types

      delegate :size, :each, to: :collection_types

      def initialize(collection_types)
        @collection_types = collection_types
      end

      def english?
        I18n.locale == :en
      end
    end
  end
end
