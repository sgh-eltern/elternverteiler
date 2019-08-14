# frozen_string_literal: true

require 'sgh/elternverteiler/with_mailing_list'

module SGH
  module Elternverteiler
    class Klasse < Sequel::Model(:klasse)
      include FormeHelper
      include Comparable
      extend WithMailingList

      one_to_many :schüler, class: Schüler
      many_to_one :stufe, class: Klassenstufe

      many_to_many :ämter,
                   class: Amt,
                   join_table: :amtsperioden,
                   left_key: :klasse_id,
                   right_key: :amt_id

      with_mailing_list(
        name: lambda { |k| "Eltern der #{k}" },
        address: lambda { |k| "eltern-#{k.name}" },
        members: :eltern
      )

      def before_destroy
        # destroy all parents that have no other kid in school besides this
        eltern.each do |ezb|
          ezb.destroy unless ezb.kinder.any? { |kind| kind.klasse != self }
        end
      end

      def eltern
        schüler.collect(&:eltern).flatten.uniq.tap do |all|
          k = self

          all.define_singleton_method(:mailing_list) do
            MailingList.new(
              name: "Eltern der #{k}",
              address: "eltern-#{k.name}",
              members: self
            )
          end
        end
      end

      def elternvertreter
        Amtsperiode.where(
          amt: Amt.where(Sequel.like(:name, '%Klassenelternvertreter')),
          klasse: self
        ).map(&:inhaber).tap do |all|
          k = self

          all.define_singleton_method(:mailing_list) do
            MailingList.new(
              name: "Elternvertreter der #{k}",
              address: "elternvertreter-#{k.name}",
              members: self
            )
          end
        end
      end

      def name
        [stufe.name, zug].join
      end

      def to_s
        "Klasse #{name}"
      end

      def <=>(other)
        [stufe, zug] <=> [other.stufe, other.zug]
      end

      def validate
        super
        if !zug.to_s.empty?
          existing = Klasse[{ stufe: stufe, zug: zug.swapcase }]

          if existing
            errors.add(:zug, "#{existing.zug} existiert bereits (Groß- und Kleinschreibung wird nicht unterschieden)")
          end
        elsif stufe.name.start_with?('J')
          existing = Klasse[{ stufe: stufe, zug: nil }]

          if existing
            errors.add(:stufe, "#{existing} existiert bereits")
          end
        else
          errors.add(:zug, 'darf nicht leer sein (außer in der Jahrgangsstufe)')
        end
      end
    end
  end
end
