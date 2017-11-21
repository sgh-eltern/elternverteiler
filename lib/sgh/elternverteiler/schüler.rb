# frozen_string_literal: true

module SGH
  module Elternverteiler
    class Schüler < Sequel::Model(:schüler)
      many_to_many :eltern,
        left_key: :schüler_id,
        right_key: :erziehungsberechtigter_id,
        join_table: :erziehungsberechtigung,
        class: Erziehungsberechtigter

      many_to_one :klasse, class: Klasse

      def before_destroy
        # destroy all parents that have no other kid in school besides this
        eltern.each { |ezb| ezb.destroy if ezb.kinder.size == 1 }
      end

      def to_s
        "#{vorname} #{nachname}, #{klasse}"
      end
    end
  end
end
