# frozen_string_literal: true

module SGH
  module Elternverteiler
    class Schüler < Sequel::Model(:schüler)
      many_to_many :eltern,
        class: Erziehungsberechtigter,
        join_table: :erziehungsberechtigung,
        left_key: :schüler_id,
        right_key: :erziehungsberechtigter_id

      many_to_one :klasse, class: Klasse

      def before_destroy
        # destroy all parents that have no other kid in school besides this
        eltern.each { |ezb| ezb.destroy if ezb.kinder.size == 1 }
      end

      def to_s
        "#{vorname} #{nachname}, #{klasse}"
      end

      def forme_namespace
        self.class.name.tr(':', '-')
      end
    end
  end
end
