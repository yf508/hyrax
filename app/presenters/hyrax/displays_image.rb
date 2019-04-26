require 'iiif_manifest'

module Hyrax
  # This gets mixed into FileSetPresenter in order to create
  # a canvas on a IIIF manifest
  module DisplaysImage
    extend ActiveSupport::Concern

    # Creates a display image only where FileSet is an image.
    #
    # @return [IIIFManifest::DisplayImage] the display image required by the manifest builder.
    def display_image
      return nil unless ::FileSet.exists?(id) && solr_document.image? && current_ability.can?(:read, id)
      # @todo this is slow, find a better way (perhaps index iiif url):
      # original_file = ::FileSet.find(id).original_file
      latest_file_id = solr_document['current_file_version_ssi']

      url = Hyrax.config.iiif_image_url_builder.call(
        latest_file_id,
        request.base_url,
        Hyrax.config.iiif_image_size_default
      )
      # @see https://github.com/samvera-labs/iiif_manifest
      IIIFManifest::DisplayImage.new(url,
                                     width: 640,
                                     height: 480,
                                     iiif_endpoint: iiif_endpoint(latest_file_id))
    end

    private

      def iiif_endpoint(file_id)
        return unless Hyrax.config.iiif_image_server?
        IIIFManifest::IIIFEndpoint.new(
          Hyrax.config.iiif_info_url_builder.call(file_id, request.base_url),
          profile: Hyrax.config.iiif_image_compliance_level_uri
        )
      end
  end
end
