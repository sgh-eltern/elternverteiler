require 'pathname'

module SGH
  module Elternverteiler
    module Recovery
      class Manager
        class DuplicateName < StandardError
          def initialize(offending_name)
            super("Ein Backup namens #{offending_name} existiert bereits.")
          end
        end

        def initialize(root)
          @root = Pathname(root)
        end

        def all
          @root.children.map { |f| Backup.new(f.basename.sub_ext(''), f.mtime) }
        end

        def backup(backup)
          raise "Backup is required" unless backup
          raise "Backup name is required" unless backup.name
          path = path(backup)
          raise DuplicateName.new(backup.name) if path.exist?
          warn "Creating backup #{path}"
        end

        def restore(backup)
          path = path(backup)
          raise "Could not find #{backup.name}" unless path.exist? && path.file?
          warn "Restoring backup #{path}"
        end

        private

        def path(backup)
          (@root / backup.name).sub_ext('.tgz')
        end
      end
    end
  end
end

__END__

pg_dump --clean $DB | gzip > backup-$(date "+%FT%T%z").tgz
gunzip -c backup-2018-02-13T18:56:14+0100.tgz | less
