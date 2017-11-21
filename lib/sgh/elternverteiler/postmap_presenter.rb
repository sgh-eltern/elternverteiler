# frozen_string_literal: true

module SGH
  module Elternverteiler
    class PostmapPresenter
      def initialize(address)
        @address = address
      end

      def present(exhibit)
        return '' if exhibit.empty?
        "#{@address} #{exhibit.map(&:mail).uniq.compact.join(',')}"
      end
    end
  end
end
