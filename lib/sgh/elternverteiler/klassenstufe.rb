# frozen_string_literal: true

module SGH
  module Elternverteiler
    class Klassenstufe < Sequel::Model(:klassenstufe)
      include FormeHelper
      include Comparable
      extend WithMailingList

      one_to_many :klassen, class: Klasse, key: :stufe_id

      def schüler
        Schüler.where(klasse: Klasse.where(stufe: self))
      end

      with_mailing_list(
        name: lambda { |k| "Eltern der #{k}" },
        address: lambda { |k| "eltern-#{k.name.downcase}" },
        members: :eltern
      )

      def eltern
        klassen.collect(&:eltern).flatten.uniq.tap do |all|
          k = self

          all.define_singleton_method(:mailing_list) do
            MailingList.new(
              name: "Eltern der #{k}",
              address: "eltern-#{k.name}",
              members: all
            )
          end
        end
      end

      def elternvertreter
        klassen.collect(&:elternvertreter).flatten.uniq.tap do |all|
          k = self

          all.define_singleton_method(:mailing_list) do
            MailingList.new(
              name: "Elternvertreter der #{k}",
              address: "elternvertreter-#{k.name}",
              members: all
            )
          end
        end
      end

      def ordinal
        name.tr('J', '1').to_i
      end

      def to_s
        "Klassenstufe #{name}"
      end

      def <=>(other)
        ordinal <=> other.ordinal
      end
    end
  end
end
