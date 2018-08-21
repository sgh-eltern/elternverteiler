# frozen_string_literal: true

require 'shellwords'
require 'open3'

module SGH
  module Elternverteiler
    module Recovery
      #
      # Manages backups residing in a blobstore
      #
      class BlobstoreManager
        def initialize(bucket, db_url)
          raise 'Bucket must not be nil' if bucket.nil?
          raise 'Bucket must exist' unless bucket.exists?
          raise 'Database URL must not be empty' if db_url.to_s.empty?
          @bucket = bucket
          @db_url = db_url
        end

        def all
          @bucket.files.map do |f|
            Backup.new(
              name: f.name,
              created_at: f.created_at,
              signed_url: f.signed_url
            )
          end
        end

        def backup(backup)
          raise 'Backup is required' unless backup

          remote_file_name = backup.file_name
          raise DuplicateName.new(backup.name) if @bucket.file(remote_file_name)

          Tempfile.create do |local_file|
            local_file_path = local_file.path
            execute("set -o pipefail; pg_dump --clean #{@db_url} | gzip > #{Shellwords.escape(local_file_path)}")
            @bucket.create_file(local_file_path, remote_file_name)
          end
        end

        def restore(backup)
          raise 'Backup is required' unless backup

          Tempfile.create do |local_file|
            local_file_path = local_file.path
            @bucket.file(backup.name).download(local_file_path)
            execute("set -o pipefail; gunzip -c #{Shellwords.escape(local_file_path)} | psql --set ON_ERROR_STOP=on #{@db_url}")
          end
        end

        private

        def execute(command)
          stdout, stderr, status = Open3.capture3(command)
          raise ExecutionError.new(command, stdout, stderr, status) unless status.success?
        end
      end
    end
  end
end
