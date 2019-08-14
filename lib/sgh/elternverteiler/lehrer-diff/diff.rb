# frozen_string_literal: true

require 'hashdiff'
require 'ostruct'

module SGH
  module Elternverteiler
    module LehrerDiff
      class Diff
        attr_reader :current

        def initialize(current, incoming)
          @current = current.map(&:to_h)
          @incoming = incoming.map(&:to_h)
          @diff = HashDiff.diff(@current, @incoming).group_by(&:first)
        end

        def additions
          Array(@diff['+']).map do |addition|
            OpenStruct.new(path: addition[1], subject: addition[2])
          end
        end

        def changes
          Array(@diff['~']).map do |change|
            OpenStruct.new(path: change[1], old: change[2], new: change[3])
          end
        end

        def removals
          Array(@diff['-']).map do |removal|
            OpenStruct.new(path: removal[1], subject: removal[2])
          end
        end

        def changes?
          changes.any?
        end

        def removals?
          removals.any?
        end

        def additions?
          additions.any?
        end

        def any?
          changes? || additions? || removals?
        end

        def empty?
          !any?
        end

        def to_s
          "#{additions.size} Zugänge, #{removals.size} Abgänge, #{changes.size} Änderungen"
        end
      end
    end
  end
end
