# frozen_string_literal: true

require 'wings/converter_value_mapper'

module Wings
  ##
  # Converts `Valkyrie::Resource` objects to legacy `ActiveFedora::Base` objects.
  #
  # @example
  #   work     = GenericWork.new(title: ['Comet in Moominland'])
  #   resource = GenericWork.valkyrie_resource
  #
  #   ActiveFedoraConverter.new(resource: resource).convert == work # => true
  #
  # @note the `Valkyrie::Resource` object passed to this class **must** have an
  #   `#internal_resource` mapping it to an `ActiveFedora::Base` class.
  class ActiveFedoraConverter
    ##
    # Accesses the Class implemented for handling resource attributes
    # @return [Class]
    def self.attributes_class
      ActiveFedoraAttributes
    end

    ##
    # @!attribute [rw] resource
    #   @return [Valkyrie::Resource]
    attr_accessor :resource

    ##
    # @param [Valkyrie::Resource]
    def initialize(resource:)
      @resource = resource
    end

    ##
    # Accesses and parses the attributes from the resource
    # @return [Hash]
    def attributes
      wrapper = self.class.attributes_class.new(resource.attributes)
      wrapper.result
    end

    ##
    # @return [ActiveFedora::Base]
    def convert
      active_fedora_class.new(normal_attributes).tap do |af_object|
        af_object.id = id unless id.empty?
        af_object.visibility = attributes[:visibility] unless attributes[:visibility].blank?
        convert_members(af_object)
        convert_member_of_collections(af_object)
      end
    end

    def active_fedora_class
      klass = resource.internal_resource.constantize
      return klass if klass <= ActiveFedora::Base
      DefaultWork
    end

    ##
    # In the context of a Valkyrie resource, prefer to use the id if it
    # is provided and fallback to the first of the alternate_ids. If all else fails
    # then the id hasn't been minted and shouldn't yet be set.
    # @return [String]
    def id
      id_attr = resource[:id]
      return id_attr.to_s if id_attr.present? && id_attr.is_a?(::Valkyrie::ID) && !id_attr.blank?
      return "" unless resource.respond_to?(:alternate_ids)
      resource.alternate_ids.first.to_s
    end

    # A dummy work class for valkyrie resources that don't have corresponding
    # hyrax ActiveFedora::Base models.
    #
    # A possible improvement would be to dynamically generate properties based
    # on what's found in the resource.
    class DefaultWork < ActiveFedora::Base
      include Hyrax::WorkBehavior
      property :ordered_authors, predicate: ::RDF::Vocab::DC.creator
      property :ordered_nested, predicate: ::RDF::URI("http://example.com/ordered_nested")
      property :nested_resource, predicate: ::RDF::URI("http://example.com/nested_resource"), class_name: "Wings::ActiveFedoraConverter::NestedResource"
      include ::Hyrax::BasicMetadata
      accepts_nested_attributes_for :nested_resource

      # self.indexer = <%= class_name %>Indexer
    end

    class NestedResource < ActiveTriples::Resource
      property :title, predicate: ::RDF::Vocab::DC.title
      property :ordered_authors, predicate: ::RDF::Vocab::DC.creator
      property :ordered_nested, predicate: ::RDF::URI("http://example.com/ordered_nested")
      def initialize(uri = RDF::Node.new, _parent = ActiveTriples::Resource.new)
        uri = if uri.try(:node?)
                RDF::URI("#nested_resource_#{uri.to_s.gsub('_:', '')}")
              elsif uri.to_s.include?('#')
                RDF::URI(uri)
              end
        super
      end
      include ::Hyrax::BasicMetadata
    end

    private

      def convert_members(af_object)
        return unless resource.respond_to?(:member_ids) && !resource.member_ids.blank?
        # TODO: It would be better to find a way to add the members without resuming all the member AF objects
        temp_object = assemble_members(af_object)
        af_object.ordered_member_proxies.association.replace temp_object.ordered_member_proxies.association.to_a
        af_object.members.proxy_association.target.concat temp_object.members.proxy_association.target
        af_object
      end

      def assemble_members(af_object)
        temp_object = af_object.class.new
        resource.member_ids.each do |valkyrie_id|
          temp_object.ordered_members << ActiveFedora::Base.find(valkyrie_id.id)
        end
        temp_object.ordered_member_proxies.association.to_a.each do |p|
          p.proxy_in = af_object
        end
        temp_object
      end

      def convert_member_of_collections(af_object)
        return unless resource.respond_to?(:member_of_collection_ids) && resource.member_of_collection_ids
        # TODO: It would be better to find a way to set the parent collections without resuming all the collection AF objects
        member_of_collections = []
        resource.member_of_collection_ids.each do |valkyrie_id|
          member_of_collections << ActiveFedora::Base.find(valkyrie_id.id)
        end
        af_object.member_of_collections = member_of_collections
      end

      # Normalizes the attributes parsed from the resource
      #   (This ensures that scalar values are passed to the constructor for the
      #   ActiveFedora::Base Class)
      # @return [Hash]
      def normal_attributes
        normalized = {}
        attributes.each_pair do |attr, value|
          property = active_fedora_class.properties[attr.to_s]
          # This handles some cases where the attributes do not directly map to an
          #   RDF property value
          normalized[attr] = value
          next if property.nil?
          normalized[attr] = Array.wrap(value) if property.multiple?
        end
        normalized
      end
  end
end
