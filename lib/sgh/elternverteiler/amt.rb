# frozen_string_literal: true

module SGH
  module Elternverteiler
    # Rolle eines Erziehungsberechtigten als Vertreter einer Klasse
    class Amt < Sequel::Model(:ämter)
      include FormeHelper

      many_to_one :inhaber, class: Erziehungsberechtigter
      many_to_one :rolle
      many_to_one :klasse

      def to_s
        "#{rolle} Klasse #{klasse}"
      end
    end
  end
end
