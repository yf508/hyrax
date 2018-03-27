require "dry/transaction/operation"

module Hyrax
  module Transactions
    module Steps
      class CleanupFileSetsStep
        include Dry::Transaction::Operation

        def call(work)
          cleanup_file_sets(work)
          Success(work)
        end

        private

          def cleanup_file_sets(curation_concern)
            # Destroy the list source first.  This prevents each file_set from attemping to
            # remove itself individually from the work. If hundreds of files are attached,
            # this would take too long.

            # Get list of member file_sets from Solr
            fs = curation_concern.file_sets
            curation_concern.list_source.destroy
            # Remove Work from Solr after it was removed from Fedora so that the
            # in_objects lookup does not break when FileSets are destroyed.
            ActiveFedora::SolrService.delete(curation_concern.id)
            fs.each(&:destroy)
          end
      end
    end
  end
end
