# frozen_string_literal: true

require 'sgh/elternverteiler/lehrer_factory'
require 'nokogiri'

module SGH
  module Elternverteiler
    class LehrerMapper
      def map(html)
        factory = LehrerFactory.new
        lehrer = Nokogiri::HTML(html).xpath('//table/tbody/tr[position() > 1]').map do |tr|
          factory.
            map(tr.xpath('td/text()').
            map(&:to_s).map(&:strip))
        end.compact

        lehrer.group_by{|l| l.nachname}.each do |nachname, lehrer|
          if lehrer.size == 1
            l = lehrer.first
            l.email = email(l.nachname)
            l.save
          else
            lehrer.each do |l|
              l.email = email(l.nachname, l.vorname)
              l.save
            end
          end
        end

        lehrer
      end

      private

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
    end
  end
end
