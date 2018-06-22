# frozen_string_literal: true

module SGH
  module Elternverteiler
    MailingList = Struct.new(:name, :address, :members, keyword_init: true) do
      class << self
        def first!(address:)
          raise "MailingList '#{address}' is to be implemented"
        end
      end

      def address(format=:short)
        case format
        when :short
          self[:address]
        when :long
          "#{self[:address]}@schickhardt-gymnasium-herrenberg.de"
        else
          raise "Unknown format #{format}"
        end
      end

      def url
        "/verteiler/#{self[:address]}"
      end
    end
  end
end
