# frozen_string_literal: true

module SGH
  module Elternverteiler
    class Klasse < Sequel::Model(:klasse)
      include FormeHelper
      include Comparable

      one_to_many :schüler, class: Schüler

      many_to_many :rollen,
        class: Rolle,
        join_table: :ämter,
        left_key: :klasse_id,
        right_key: :rolle_id

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
        ).map(&:inhaber)
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
