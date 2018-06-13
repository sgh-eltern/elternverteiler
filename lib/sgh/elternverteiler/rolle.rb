# frozen_string_literal: true

module SGH
  module Elternverteiler
    class Rolle < Sequel::Model(:rollen)
      include FormeHelper
      include Comparable

      many_to_many :mitglieder,
        class: Erziehungsberechtigter,
        join_table: :ämter,
        left_key: :rolle_id,
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
