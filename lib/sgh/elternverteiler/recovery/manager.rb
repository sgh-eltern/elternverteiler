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
            @command, @stdout, @stderr, @status = command, stdout, stderr, status
          end
        end

        def initialize(root)
          @root = Pathname(root)
        end

        def all
          @root.glob('*.tgz').map { |f| Backup.new(f.basename.sub_ext(''), f.mtime) }
        end

        def backup(backup)
          raise 'Backup is required' unless backup
          raise 'Backup name is required' unless backup.name
          path = path(backup)
          raise DuplicateName.new(backup.name) if path.exist?
          execute("set -o pipefail; pg_dump --clean #{ENV.fetch('DB')} | gzip > #{ Shellwords.escape(path)}")
        end

        def restore(backup)
          path = path(backup)
          raise "Could not find #{backup.name}" unless path.exist? && path.file?
          execute("set -o pipefail; gunzip -c #{ Shellwords.escape(path)} | psql #{ENV.fetch('DB')}")
        end

        private

        def path(backup)
          (@root / backup.name).sub_ext('.tgz')
        end

        def execute(command)
          stdout, stderr, status = Open3.capture3(command)
          raise ExecutionError.new(command, stdout, stderr, status) unless status.success?
        end
      end
    end
  end
end
