# frozen_string_literal: true

require 'sgh/elternverteiler/with_mailing_list'

module SGH
  module Elternverteiler
    class Amt < Sequel::Model(:ämter)
      include FormeHelper
      include Comparable
      extend WithMailingList
      one_to_many :amtsperioden, class: Amtsperiode

      with_mailing_list(
        name: self,
        address: lambda { |a| a.name }, # TODO Replace with :name once WithMailingList understands symbols for the address
        members: :inhaber
      )

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
