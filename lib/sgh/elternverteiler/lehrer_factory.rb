# frozen_string_literal: true

require 'nokogiri'
require 'sgh/elternverteiler/fach_mapper'

module SGH
  module Elternverteiler
    class LehrerFactory
      def map(attributes)
        if attributes[1].start_with?('Dr. ')
          titel = 'Dr.'
          nachname = attributes[1].split('Dr. ').last
        else
          nachname = attributes[1]
        end

        Lehrer.find_or_create(
          kürzel: attributes[0],
          titel: titel,
          nachname: nachname,
          vorname: attributes[2],
        ).tap do |l|
          fächer(attributes[3]).each do |fach|
            l.add_fächer(fach)
          end
        end
      end

      private

      def fächer(text)
        FachMapper.new.map(*(text.split(',').map(&:strip)))
      end
    end
  end
end
