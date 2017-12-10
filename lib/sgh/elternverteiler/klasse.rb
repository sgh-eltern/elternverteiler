# frozen_string_literal: true

module SGH
  module Elternverteiler
    class Klasse < Sequel::Model(:klasse)
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
        Amt.where(rolle: roles, klasse: self).map(&:erziehungsberechtigter)
      end

      def to_s
        "#{stufe}#{zug}"
      end
    end
  end
end
