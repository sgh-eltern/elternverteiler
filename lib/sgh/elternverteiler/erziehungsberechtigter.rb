# frozen_string_literal: true

module SGH
  module Elternverteiler
    class Erziehungsberechtigter < Sequel::Model(:erziehungsberechtigte)
      include FormeHelper

      many_to_many :kinder,
                   class: Schüler,
                   join_table: :erziehungsberechtigung,
                   left_key: :erziehungsberechtigter_id,
                   right_key: :schüler_id

      many_to_many :ämter,
                   class: Amt,
                   join_table: :amtsperioden,
                   left_key: :inhaber_id,
                   right_key: :amt_id

      ValidationError = Class.new(StandardError)

      def amtsperioden
        ämter.map { |r| SGH::Elternverteiler::Amtsperiode.where(amt: r, inhaber: self).all }.flatten.uniq
      end

      def before_save
        if vorname.to_s.empty? && nachname.to_s.empty? && mail.to_s.empty?
          raise ValidationError.new('Mindestens eines der Attribute Vorname, Nachname oder Mail wird benötigt.')
        end

        super
      end

      def name
        if vorname.to_s.empty?
          nachname
        else
          "#{nachname}, #{vorname}"
        end
      end

      def self.all
        super.tap do |all|
          all.define_singleton_method(:mailing_list) do
            MailingList.new(
              name: 'Alle Eltern',
              address: 'eltern',
              members: all
            )
          end
        end
      end

      def <=>(other)
        [nachname.to_s, vorname.to_s, mail.to_s] <=> [other.nachname.to_s, other.vorname.to_s, other.mail.to_s]
      end

      def to_s
        if vorname.to_s.empty? && nachname.to_s.empty?
          mail
        elsif mail.to_s.empty?
          "#{vorname} #{nachname}".strip
        else
          "#{vorname} #{nachname} <#{mail}>".strip
        end
      end
    end
  end
end
