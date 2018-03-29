require "dry/transaction/operation"

module Hyrax
  module Transactions
    module Steps
      class ValidateFilesStep
        include Dry::Transaction::Operation

        def call(env)
          uploaded_file_ids = filter_file_ids(env[:attributes].delete(:uploaded_files))
          files = uploaded_files(uploaded_file_ids)
          Success(env) if validate_files(user: env[:ability].current_user, files: files)
          Failure(:file_owned_by_different_user)
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

          # ensure that the files we are given are owned by the depositor of the work
          def validate_files(user:, files:)
            expected_user_id = user.id
            files.each do |file|
              if file.user_id != expected_user_id
                Rails.logger.error "User #{user.user_key} attempted to ingest uploaded_file #{file.id}, but it belongs to a different user"
                return false
              end
            end
            true
          end
      end
    end
  end
end
