# frozen_string_literal: true
module Hyrax
  class PermissionTemplateApplicator
    ##
    # @!attribute [rw] template
    #   @return [Hyrax::PermissionTemplate]
    attr_accessor :template

    ##
    # @param template [Hyrax::PermissionTemplate]
    def initialize(template:)
      self.template = template
    end

    def self.apply(template)
      new(template: template)
    end

    ##
    # @param model [Hydra::PCDM::Object, Hydra::PCDM::Collection]
    # @return [Boolean] true if the permissions have been successfully applied
    def apply_to(model:)
      model.edit_users  += template.agent_ids_for(agent_type: 'user',  access: 'manage')
      model.read_users  += template.agent_ids_for(agent_type: 'user',  access: 'view')
      model.edit_groups += template.agent_ids_for(agent_type: 'group', access: 'manage')
      model.read_groups += template.agent_ids_for(agent_type: 'group', access: 'view')

      true
    end
    alias to apply_to
  end
end
