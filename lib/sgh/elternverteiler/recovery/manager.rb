# frozen_string_literal: true

require 'pathname'
require 'shellwords'
require 'open3'

module SGH
  module Elternverteiler
    module Recovery
      class Manager
        class DuplicateName < StandardError
          def initialize(offending_name)
            super("Ein Backup namens #{offending_name} existiert bereits.")
          end
        end

        class ExecutionError < StandardError
          attr_reader :command, :stdout, :stderr, :status

          def initialize(command, stdout, stderr, status)
            @command = command
            @stdout = stdout
            @stderr = stderr
            @status = status
            super(stderr)
          end
        end

        def initialize(root, db_url)
          raise 'Root directory is required' unless root
          @root = Pathname(root)
          raise 'Backup directory does not exist' unless @root.exist?

          raise 'Database URL is required' if db_url.to_s.empty?
          @db_url = db_url
        end

        def all
          @root.glob('*.gz').map { |f| Backup.new(f.basename.sub_ext(''), f.mtime) }
        end

        def backup(backup)
          raise 'Backup is required' unless backup
          raise 'Backup name is required' unless backup.name
          path = path(backup)
          raise DuplicateName.new(backup.name) if path.exist?
          execute("set -o pipefail; pg_dump --clean #{@db_url} | gzip > #{Shellwords.escape(path)}")
        end

        def restore(backup)
          path = path(backup)
          raise "Could not find #{backup.name}" unless path.exist? && path.file?
          execute("set -o pipefail; gunzip -c #{Shellwords.escape(path)} | psql --set ON_ERROR_STOP=on #{@db_url}")
        end

        private

        def path(backup)
          (@root / backup.name).sub_ext('.gz')
        end

        def execute(command)
          stdout, stderr, status = Open3.capture3(command)
          raise ExecutionError.new(command, stdout, stderr, status) unless status.success?
        end
      end
    end
  end
end
