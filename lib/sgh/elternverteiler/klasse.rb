# frozen_string_literal: true

module SGH
  module Elternverteiler
    # TODO: Each arg can either be a symbol (method to send to self) or a proc
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

      many_to_many :rollen,
        class: Rolle,
        join_table: :ämter,
        left_key: :klasse_id,
        right_key: :rolle_id

      with_mailing_list(
        name: lambda { |k| "Eltern der #{k}" },
        address: lambda { |k| "eltern-#{k.to_s.downcase}" },
        members: :eltern
      )

      def eltern
        schüler.collect(&:eltern).flatten.uniq
      end

      def inhaber(*roles)
        Amt.where(rolle: roles, klasse: self).map(&:inhaber)
      end

      def elternvertreter
        Amt.where(
          rolle: Rolle.where(Sequel.like(:name, '%.EV')),
          klasse: self
        ).map(&:inhaber).tap do |ev|
          k = self

          ev.define_singleton_method(:mailing_list) do
            MailingList.new(
              name: "Elternvertreter der #{k}",
              address: "elternvertreter-#{k.to_s.downcase}",
              members: self
            )
          end
        end
      end

      def to_s
        "#{stufe}#{zug}"
      end

      alias_method :name, :to_s

      def <=>(other)
        if numeric?(stufe) && numeric?(other.stufe)
          [stufe.to_i, zug] <=> [other.stufe.to_i, other.zug]
        elsif !numeric?(stufe) && !numeric?(other.stufe)
          [stufe, zug] <=> [other.stufe, other.zug]
        elsif numeric?(stufe) && !numeric?(other.stufe)
          -1
        elsif !numeric?(stufe) && numeric?(other.stufe)
          1
        else
          raise "Unable to compare #{self} with #{other}"
        end
      end

      def numeric?(value)
        value.to_i.to_s == value
      end
    end
  end
end
