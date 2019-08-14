# frozen_string_literal: true

module SGH
  module Elternverteiler
    module LehrerDiff
      DTO = Struct.new(:kürzel, :nachname, :vorname, :fächer, keyword_init: true) do
        def self.build(lehrer)
          new(kürzel: lehrer.kürzel,
              nachname: lehrer.titel ? "#{lehrer.titel} #{lehrer.nachname}" : lehrer.nachname,
              vorname: lehrer.vorname,
              fächer: lehrer.fächer.map { |fach|
                if fach.respond_to?(:kürzel)
                  fach.kürzel
                else
                  fach
                end
              }.sort)
        end
      end
    end
  end
end
