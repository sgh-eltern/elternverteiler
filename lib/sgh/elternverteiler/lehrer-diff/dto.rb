# frozen_string_literal: true

module SGH
  module Elternverteiler
    module LehrerDiff
      DTO = Struct.new(:kürzel, :titel, :nachname, :vorname, :email, :fächer, keyword_init: true) do
        def self.build(lehrer)
          new(kürzel: lehrer.kürzel,
              titel: lehrer.titel,
              nachname: lehrer.nachname,
              vorname: lehrer.vorname,
              email: lehrer.email,
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
