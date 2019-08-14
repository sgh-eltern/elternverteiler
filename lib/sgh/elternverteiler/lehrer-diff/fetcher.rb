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
          end.compact
        end
      end
    end
  end
end
