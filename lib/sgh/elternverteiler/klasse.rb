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
        address: lambda { |k| "eltern-#{k.to_s.downcase}" },
        members: :eltern
      )

      def eltern
        schüler.collect(&:eltern).flatten.uniq
      end

      def inhaber(*roles)
        Amtsperiode.where(amt: roles, klasse: self).map(&:inhaber)
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
              address: "elternvertreter-#{k.to_s.downcase}",
              members: self
            )
          end
        end
      end

      def to_s
        "#{stufe.name}#{zug}"
      end

      alias_method :name, :to_s

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
