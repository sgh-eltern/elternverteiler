# frozen_string_literal: true

module SGH
  module Elternverteiler
    class Klasse < Sequel::Model(:klasse)
      one_to_many :schüler, class: Schüler

      many_to_many :eltern,
        left_key: :erziehungsberechtigter_id,
        right_key: :schüler_id,
        join_table: :erziehungsberechtigung,
        class: Erziehungsberechtigter

      def to_s
        "#{stufe}#{zug}"
      end
    end
  end
end
