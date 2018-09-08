# frozen_string_literal: true

require 'time'
require 'pathname'

module SGH
  module Elternverteiler
    module Recovery
      class Backup
        attr_accessor :name
        attr_reader :created_at
        attr_reader :signed_url

        def initialize(name: Time.now.iso8601, created_at: nil, signed_url: nil)
          raise 'Name is required' if name.to_s.empty?
          @name = name
          @created_at = created_at
          @signed_url = signed_url
        end

        def file_name
          Pathname(name).sub_ext('.gz').to_s
        end

        def <=>(other)
          [other.created_at, other.name] <=> [created_at, name]
        end
      end
    end
  end
end
