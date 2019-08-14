# frozen_string_literal: true

require 'sgh/elternverteiler/lehrer-diff/diff'
require 'sgh/elternverteiler/lehrer-diff/lehrer_presenter'

module SGH
  module Elternverteiler
    module LehrerDiff
      class CliPresenter
        private

        attr_reader :diff

        public

        def initialize(diff)
          @diff = diff
        end

        def present(stream)
          present_additions(stream)
          stream.puts
          present_changes(stream)
          stream.puts
          present_removals(stream)
        end

        #
        # Determine the exit code. It reflects which changes happened:
        #
        # XXX
        # ||+ additions
        # |+- changes
        # +-- deletions
        #
        # 000 = 0 => everything is the same
        # 001 = 1 => there were additions
        # 010 = 2 => there were changes
        # 011 = 3 => there were additions and changes
        # 100 = 4 => there were deletions
        # 101 = 5 => there were additions and deletions
        # 110 = 6 => there were changes and deletions
        # 111 = 7 => there were additions, changes and deletions
        #
        def exit_code
          additions = diff.additions? ? 1 : 0
          changes = diff.changes? ? 2 : 0
          deletions = diff.removals? ? 3 : 0

          deletions + additions + changes
        end

        private

        def present_additions(stream)
          stream.puts 'Neuzugänge'
          if diff.additions?
            stream.puts diff.additions.map { |addition| "  #{LehrerPresenter.new(addition.subject)}" }
          else
            stream.puts '  -'
          end
        end

        def present_changes(stream)
          stream.puts 'Änderungen'
          if diff.changes?
            stream.puts diff.changes.map { |change|
              changed_attrs = change.path.split('.')
              subject = diff.current.instance_eval("self#{changed_attrs.first}")

              "  #{LehrerPresenter.new(subject)}: #{changed_attrs.last.capitalize} #{change.old} => #{change.new}"
            }
          else
            stream.puts '  -'
          end
        end

        def present_removals(stream)
          stream.puts 'Abgänge'
          if diff.removals?
            stream.puts diff.removals.map { |removal| "  #{LehrerPresenter.new(removal.subject)}" }
          else
            stream.puts '  -'
          end
        end
      end
    end
  end
end
