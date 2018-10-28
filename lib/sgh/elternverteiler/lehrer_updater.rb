# frozen_string_literal: true

require 'sequel'
require 'sgh/elternverteiler'
require 'sgh/elternverteiler/lehrer_mapper'
require 'open-uri'

module SGH
  module Elternverteiler
    class LehrerUpdater
      def initialize
        @html = open('http://www.schickhardt.net/?page_id=90').read
        @lehrer_mapper = LehrerMapper.new
      end

      def call
        Sequel::Model.db.transaction do
          Lehrer.dataset.destroy
          Fach.dataset.destroy
          @lehrer_mapper.map(@html)
        end
      end
    end
  end
end
