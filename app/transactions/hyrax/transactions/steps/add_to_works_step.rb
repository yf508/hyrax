require "dry/transaction/operation"

module Hyrax::Transactions::Steps
  class AddToWorksStep
    include Dry::Transaction::Operation

    attr_reader :ability

    # @param [Hash] env
    def call(env)
      @ability = env[:ability]
      work_ids = env[:attributes].delete(:in_works_ids)
      add_to_works(env[:work], work_ids)
      Success(env)
    end

    private

      def can_edit_both_works?(work1:, work2:)
        ability.can?(:edit, work1) && ability.can?(:edit, work2)
      end

      def add_to_works(work, new_work_ids)
        return true if new_work_ids.nil?
        cleanup_ids_from_works(work: work, new_work_ids: new_work_ids)
        add_work_ids_to_work(work: work, new_work_ids: new_work_ids)
        work.errors[:in_works_ids].empty?
      end

      def cleanup_ids_from_works(work:, new_work_ids:)
        (work.in_works_ids - new_work_ids).each do |old_id|
          old_work = ::ActiveFedora::Base.find(old_id)
          old_work.ordered_members.delete(work)
          old_work.members.delete(work)
          old_work.save!
        end
      end

      def add_work_ids_to_work(work:, new_work_ids:)
        # add to new so long as the depositor for the parent and child matches, otherwise inject an error
        (new_work_ids - work.in_works_ids).each do |work_id|
          new_work = ::ActiveFedora::Base.find(work_id)
          if can_edit_both_works?(work, new_work)
            new_work.ordered_members << work
            new_work.save!
          else
            work.errors[:in_works_ids] << "Works can only be related to each other if user has ability to edit both."
          end
        end
      end
  end
end
