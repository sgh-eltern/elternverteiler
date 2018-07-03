# frozen_string_literal: true

require 'sgh/elternverteiler/recovery/blobstore_manager'
require 'sgh/elternverteiler/recovery/backup'

module SGH
  module Elternverteiler
    module Recovery
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
    end
  end
end
