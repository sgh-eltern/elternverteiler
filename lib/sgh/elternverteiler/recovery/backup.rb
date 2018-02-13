# frozen_string_literal: true

require 'time'

module SGH
  module Elternverteiler
    module Recovery
      class Backup
        attr_accessor :name
        attr_reader :created_at

        def initialize(name=Time.now.iso8601, created_at=nil)
          raise 'Name is required' if name.to_s.empty?
          @name = name
          @created_at = created_at
        end
      end
    end
  end
end
