# frozen_string_literal: true
module Hyrax
  module Transactions
    class DestroyWork
      include Dry::Transaction(container: Hyrax::Transactions::Container)

      step :cleanup_features,  with: 'work.cleanup_features'
      step :cleanup_trophies,  with: 'work.cleanup_trophies'
      step :destroy_file_sets, with: 'work.destroy_file_sets'
      step :destroy_work,      with: 'work.destroy_work'
    end
  end
end
