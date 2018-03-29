require "dry/transaction/operation"

module Hyrax
  module Transactions
    module Steps
      class AttachFilesStep
        include Dry::Transaction::Operation

        def call(env)
          uploaded_file_ids = filter_file_ids(env[:attributes].delete(:uploaded_files))
          files = uploaded_files(uploaded_file_ids)
          attach_files(work: env[:work], attributes: env[:attributes], files: remote_files)
          Success(env)
        end

        private

          def filter_file_ids(input)
            Array.wrap(input).select(&:present?)
          end

          # Fetch uploaded_files from the database
          def uploaded_files(uploaded_file_ids)
            return [] if uploaded_file_ids.empty?
            UploadedFile.find(uploaded_file_ids)
          end

          # @return [TrueClass]
          def attach_files(work:, attributes:, files:)
            return true if files.blank?
            AttachFilesToWorkJob.perform_later(work, files, attributes.to_h.symbolize_keys)
            true
          end
      end
    end
  end
end
