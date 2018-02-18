# frozen_string_literal: true

module SGH
  module Elternverteiler
    class Erziehungsberechtigter < Sequel::Model(:erziehungsberechtigte)
      many_to_many :kinder,
        class: Schüler,
        join_table: :erziehungsberechtigung,
        left_key: :erziehungsberechtigter_id,
        right_key: :schüler_id

      many_to_many :rollen,
        class: Rolle,
        join_table: :ämter,
        left_key: :inhaber_id,
        right_key: :rolle_id

      ValidationError = Class.new(StandardError)

      # rubocop:disable Naming/MethodName
      def ämter
        rollen.map { |r| SGH::Elternverteiler::Amt.where(rolle: r, inhaber: self).all }.flatten.uniq
      end
      # rubocop:enable Naming/MethodName

      def before_save
        if vorname.to_s.empty? && nachname.to_s.empty? && mail.to_s.empty?
          raise ValidationError.new('At least one of vorname, nachname, or mail is required')
        end

        super
      end

      def name
        if vorname.to_s.empty?
          nachname
        else
          "#{nachname}, #{vorname}"
        end.strip
      end

      def to_s
        "#{vorname} #{nachname} <#{mail}>".strip
      end

      def forme_namespace
        self.class.name.tr(':', '-')
      end
    end
  end
end
