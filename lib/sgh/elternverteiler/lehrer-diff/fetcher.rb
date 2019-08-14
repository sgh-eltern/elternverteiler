# frozen_string_literal: true

require 'open-uri'
require 'nokogiri'

module SGH
  module Elternverteiler
    module LehrerDiff
      #
      # Fetches the raw data without any mapping
      #
      class Fetcher
        def initialize(uri='http://www.schickhardt.net/?page_id=90')
          @html = open(uri).read
        end

        def fetch
          Nokogiri::HTML(@html).xpath('//table/tbody/tr[position() > 1]').map do |tr|
            values = tr.xpath('td/text()').map(&:to_s).map(&:strip)
            next if values.empty?

            values[-1] = values.last.split(',').map(&:strip).sort
            OpenStruct.new(Hash[%i[kürzel nachname vorname fächer].zip(values)])
          end.compact.tap do |result|
            result.each do |l|
              separate_title(l)
            end
            assign_email(result)
          end
        end

        private

        def assign_email(lehrer)
          lehrer.group_by(&:nachname).each do |nachname, group|
            if group.size == 1
              l = group.first
              l.email = email(l.nachname)
            else
              group.each do |l|
                l.email = email(l.nachname, l.vorname)
              end
            end
          end
        end

        def email(nachname, vorname=nil)
          if vorname
            "#{local_part(vorname)[0]}.#{local_part(nachname)}@sgh-mail.de"
          else
            "#{local_part(nachname)}@sgh-mail.de"
          end
        end

        def local_part(name)
          local_part = name.dup
          local_part.downcase!
          local_part.sub!('ä', 'ae')
          local_part.sub!('ö', 'oe')
          local_part.sub!('ü', 'ue')
          local_part.sub!('ß', 'ss')
          local_part.sub!('dr. ', '')
          local_part
        end

        def separate_title(lehrer)
          nachname = lehrer.nachname

          if nachname.start_with?('Dr. ')
            lehrer.titel = 'Dr.'
            lehrer.nachname = nachname.split('Dr. ').last
          end
        end
      end
    end
  end
end
