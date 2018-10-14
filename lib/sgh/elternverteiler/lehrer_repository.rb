require 'sgh/elternverteiler/lehrer'
require 'nokogiri'
require 'forwardable'

module SGH
  module Elternverteiler
    FÄCHER = {
      'BK' => 'Bildende Kunst',
      'Bio' => 'Biologie',
      'Ch' => 'Chemie',
      'D' => 'Deutsch',
      'E' => 'Englisch',
      'Eth' => 'Ethik',
      'F' => 'Französisch',
      'G' => 'Geschichte',
      'Geo' => 'Geografie',
      'Gk' => 'Gemeinschaftskunde',
      'L' => 'Latein',
      'M' => 'Mathematik',
      'Mu' => 'Musik',
      'NwT' => 'Naturwissenschaft und Technik',
      'Ph' => 'Physik',
      'Rev' => 'Evangelische Religionslehre',
      'Rrk' => 'Katholische Religionslehre',
      'Sm' => 'Sport männlich',
      'Sp' => 'Spanisch',
      'Sw' => 'Sport weiblich',
    }

    class LehrerRepository
      class FächerMapper

        def map(kürzel)
          FÄCHER.fetch(kürzel.strip, kürzel.strip)
        end
      end

      class LehrerMapper
        def map(attributes)
          if attributes[1].start_with?('Dr. ')
            titel = 'Dr.'
            nachname = attributes[1].split('Dr. ').last
          else
            nachname = attributes[1]
          end

          Lehrer.new(
            kürzel: attributes[0],
            titel: titel,
            nachname: nachname,
            vorname: attributes[2],
            fächer: fächer(attributes[3]),
          )
        end

        private

        def fächer(text)
          fächer_mapper = FächerMapper.new
          text.split(',').map { |f| fächer_mapper.map(f) }
        end
      end

      include Enumerable
      extend Forwardable
      def_delegator :@lehrer, :each

      def initialize(html)
        lehrer_mapper = LehrerMapper.new
        @lehrer = Nokogiri::HTML(html).xpath('//table/tbody/tr[position() > 1]').map do |tr|
          lehrer_mapper.map(tr.xpath('td/text()').map(&:to_s).map(&:strip))
        end

        @lehrer.group_by{|l| l.nachname}.each do |nachname, lehrer|
          if lehrer.size == 1
            l = lehrer.first
            l.email = email(l.nachname)
          else
            lehrer.each do |l|
              l.email = email(l.nachname, l.vorname)
            end
          end
        end
      end

      def all
        @lehrer
      end

      private

      def email(nachname, vorname = nil)
        if vorname
          "#{local_part(vorname)}.#{local_part(nachname)}@sgh-mail.de"
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
