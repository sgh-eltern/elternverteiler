# frozen_string_literal: true

module SGH
  module Elternverteiler
    class Amt < Sequel::Model(:ämter)
      include FormeHelper
      include Comparable
      one_to_many :amtsperioden, class: Amtsperiode

      def inhaber
        amtsperioden.map(&:inhaber)
      end

      def to_s
        name
      end

      def <=>(other)
        name <=> other.name
      end
    end
  end
end
