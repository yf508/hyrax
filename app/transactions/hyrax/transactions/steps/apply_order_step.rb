require "dry/transaction/operation"

module Hyrax
  module Transactions
    module Steps
      class ApplyOrderStep
        include Dry::Transaction::Operation

        attr_reader :ability

        def call(env)
          @ability = env[:ability]
          work = env[:work]
          ordered_member_ids = env[:attributes].delete(:ordered_member_ids)
          sync_members(work, ordered_member_ids)
          apply_order(work, ordered_member_ids)
          Success(env)
        end

        private

          def can_edit_both_works?(work1:, work2:)
            ability.can?(:edit, work1) && ability.can?(:edit, work2)
          end

          def sync_members(work, ordered_member_ids)
            return true if ordered_member_ids.nil?
            cleanup_ids_to_remove_from_curation_concern(work, ordered_member_ids)
            add_new_work_ids_not_already_in_curation_concern(work, ordered_member_ids)
            work.errors[:ordered_member_ids].empty?
          end

          # @todo Why is this not doing work.save?
          # @see Hyrax::Actors::AddToWorkActor for duplication
          def cleanup_ids_to_remove_from_curation_concern(work, ordered_member_ids)
            (work.ordered_member_ids - ordered_member_ids).each do |old_id|
              old_work = ::ActiveFedora::Base.find(old_id)
              work.ordered_members.delete(old_work)
              work.members.delete(old_work)
            end
          end

          def add_new_work_ids_not_already_in_curation_concern(work, ordered_member_ids)
            (ordered_member_ids - work.ordered_member_ids).each do |work_id|
              new_work = ::ActiveFedora::Base.find(work_id)
              if can_edit_both_works?(work1: work, work2: new_work)
                work.ordered_members << new_work
                work.save!
              else
                work.errors[:ordered_member_ids] << "Works can only be related to each other if user has ability to edit both."
              end
            end
          end

          def apply_order(work, new_order)
            return true unless new_order
            work.ordered_member_proxies.each_with_index do |proxy, index|
              unless new_order[index]
                proxy.prev.next = work.ordered_member_proxies.last.next
                break
              end
              proxy.proxy_for = ActiveFedora::Base.id_to_uri(new_order[index])
              proxy.target = nil
            end
            work.list_source.order_will_change!
            true
          end
      end
    end
  end
end
