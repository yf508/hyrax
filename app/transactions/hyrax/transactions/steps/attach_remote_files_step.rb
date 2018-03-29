require "dry/transaction/operation"

module Hyrax
  module Transactions
    module Steps
      class AttachRemoteFilesStep
        include Dry::Transaction::Operation

        def call(env)
          remote_files = env.attributes.delete(:remote_files)
          attach_files(work: env[:work], user: env[:ability].current_user, remote_files: remote_files)
          Success(env)
        end

        private

          # @param [HashWithIndifferentAccess] remote_files
          # @return [TrueClass]
          def attach_files(work:, user:, remote_files:)
            return true unless remote_files
            remote_files.each do |file_info|
              next if file_info.blank? || file_info[:url].blank?
              # Escape any space characters, so that this is a legal URI
              uri = URI.parse(Addressable::URI.escape(file_info[:url]))
              unless validate_remote_url(uri)
                Rails.logger.error "User #{user} attempted to ingest file from url #{file_info[:url]}, which doesn't pass validation"
                return false
              end
              create_file_from_url(work: work, user: user, uri: uri, file_name: file_info[:file_name])
            end
            true
          end

          # @param uri [URI] the uri fo the resource to import
          def validate_remote_url(uri: uri)
            if uri.scheme == 'file'
              path = File.absolute_path(CGI.unescape(uri.path))
              whitelisted_ingest_dirs.any? do |dir|
                path.start_with?(dir) && path.length > dir.length
              end
            else
              # TODO: It might be a good idea to validate other URLs as well.
              #       The server can probably access URLs the user can't.
              true
            end
          end

          def whitelisted_ingest_dirs
            Hyrax.config.whitelisted_ingest_dirs
          end

          # Generic utility for creating FileSet from a URL
          # Used in to import files using URLs from a file picker like browse_everything
          def create_file_from_url(work:, user:, uri:, file_name:)
            ::FileSet.new(import_url: uri.to_s, label: file_name) do |fs|
              actor = Hyrax::Actors::FileSetActor.new(fs, user)
              actor.create_metadata(visibility: work.visibility)
              actor.attach_to_work(work)
              fs.save!
              if uri.scheme == 'file'
                # Turn any %20 into spaces.
                file_path = CGI.unescape(uri.path)
                IngestLocalFileJob.perform_later(fs, file_path, user)
              else
                ImportUrlJob.perform_later(fs, operation_for(user: actor.user))
              end
            end
          end

          def operation_for(user:)
            Hyrax::Operation.create!(user: user,
                                     operation_type: "Attach Remote File")
          end
      end
    end
  end
end
