# frozen_string_literal: true

module SGH
  module Elternverteiler
    # TODO: Each arg can either be
    # - a symbol => name of the method to send to self in order to get the value,
    # - a string => the value itself
    # - or a proc => call it with self as argument in order to get the value
    module WithMailingList
      def with_mailing_list(name:, address:, members:)
        define_method :mailing_list do
          MailingList.new(
            name: name.call(self),
            address: address.call(self),
            members: self.send(members)
          )
        end
      end
    end

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
          amt: Amt.where(Sequel.like(:name, '%.EV')),
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
          if existing = Klasse[{stufe: stufe, zug: zug.swapcase}]
            errors.add(:zug, "#{existing.zug} existiert bereits (Groß- und Kleinschreibung wird nicht unterschieden)")
          end
        else
          if stufe.name.start_with?('J')
            if existing = Klasse[{stufe: stufe}]
              errors.add(:stufe, "#{existing} existiert bereits")
            end
          else
            errors.add(:zug, 'darf nicht leer sein (außer in der Jahrgangsstufe)')
          end
        end
      end
    end
  end
end
