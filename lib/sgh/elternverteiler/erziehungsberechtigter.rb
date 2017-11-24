# frozen_string_literal: true

module SGH
  module Elternverteiler
    class Erziehungsberechtigter < Sequel::Model(:erziehungsberechtigte)
      many_to_many :kinder,
        class: Schüler,
        join_table: :erziehungsberechtigung,
        left_key: :erziehungsberechtigter_id,
        right_key: :schüler_id

      many_to_many :ämter,
        class: Rolle,
        join_table: :ämter,
        left_key: :erziehungsberechtigter_id,
        right_key: :rolle_id

        def before_save
          raise 'At least one of vorname, nachname, or mail is required' if vorname.to_s.empty? && nachname.to_s.empty? && mail.to_s.empty?
          super
        end

      def to_s
        "#{vorname} #{nachname} <#{mail}>"
      end
    end
  end
end
