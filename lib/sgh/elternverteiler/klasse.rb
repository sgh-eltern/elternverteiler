# frozen_string_literal: true

module SGH
  module Elternverteiler
    class Klasse < Sequel::Model(:klasse)
      one_to_many :schüler, class: Schüler

      def eltern
        schüler.collect(&:eltern).flatten.uniq
      end

      def to_s
        "#{stufe}#{zug}"
      end
    end
  end
end
