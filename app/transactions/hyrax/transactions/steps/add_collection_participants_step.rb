require "dry/transaction/operation"

module Hyrax::Transactions::Steps
  class AddCollectionParticipants
    include Dry::Transaction::Operation

    # @param [Hash] env
    def call(env)
      collection_ids = env[:attributes][:admin_set_id] || []
      collection_ids += env[:attributes][:collection_id] || []
      work = env[:work]
      collection_ids.each do |collection_id|
        template = Hyrax::PermissionTemplate.find_by!(source_id: collection_id)
        work.edit_users += template.agent_ids_for(agent_type: 'user', access: 'manage')
        work.edit_groups += template.agent_ids_for(agent_type: 'group', access: 'manage')
        work.read_users += template.agent_ids_for(agent_type: 'user', access: 'view')
        work.read_groups += template.agent_ids_for(agent_type: 'group', access: 'view')
      end
      Success(env)
    end
  end
end
