# frozen_string_literal: true

require 'sgh/elternverteiler/lehrer-diff/fach_mapper'

module SGH
  module Elternverteiler
    module LehrerDiff
      class Persister
        def save(lehrer)
          Lehrer.find_or_create(
            kürzel: lehrer.kürzel,
            titel: lehrer.titel,
            nachname: lehrer.nachname,
            vorname: lehrer.vorname,
            email: lehrer.email,
          ).tap do |l|
            FachMapper.new.map(*lehrer.fächer).each do |fach|
              l.add_fächer(fach)
            end
          end
        end
      end
    end
  end
end
