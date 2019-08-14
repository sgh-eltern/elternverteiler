# frozen_string_literal: true

require 'sequel'
require 'sgh/elternverteiler'
require 'sgh/elternverteiler/lehrer-diff/persister'
require 'sgh/elternverteiler/lehrer-diff/fetcher'
require 'sgh/elternverteiler/lehrer-diff/dto'
require 'sgh/elternverteiler/lehrer-diff/diff'

module SGH
  module Elternverteiler
    module LehrerDiff
      class Updater
        def call
          incoming = Fetcher.new.fetch.map { |l| DTO.build(l) }.sort_by(&:kürzel)

          if incoming.empty?
            # TODO technical alert; it is pretty unlikely the there are no teachers anymore
            return
          end

          current = Lehrer.map { |l| DTO.build(l) }.sort_by(&:kürzel)
          diff = Diff.new(current, incoming)

          warn diff

          if diff.any?
            # TODO send business alert with diff
          end

          lehrer_persister = Persister.new

          Sequel::Model.db.transaction do
            Lehrer.dataset.destroy
            Fach.dataset.destroy
            incoming.each do |lehrer|
              lehrer_persister.save(lehrer)
            end
          end
        end
      end
    end
  end
end
