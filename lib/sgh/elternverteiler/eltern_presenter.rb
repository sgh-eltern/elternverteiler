# frozen_string_literal: true

module SGH
  module Elternverteiler
    class ElternPresenter
      def initialize(address)
        @address = address
      end

      def to_s
        return '' if Erziehungsberechtigter.empty?
        "#{@address} #{Erziehungsberechtigter.all.map(&:mail).uniq.compact.join(',')}"
      end
    end
  end
end
