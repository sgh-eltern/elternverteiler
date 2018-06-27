# frozen_string_literal: true

module SGH
  module Elternverteiler
    class Amt < Sequel::Model(:ämter)
      include FormeHelper
      include Comparable

      many_to_many :inhaber,
        class: Erziehungsberechtigter,
        join_table: :amtsperioden,
        left_key: :amt_id,
        right_key: :inhaber_id

      def to_s
        name
      end

      def <=>(other)
        name <=> other.name
      end
    end
  end
end
