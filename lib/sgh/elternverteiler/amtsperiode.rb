# frozen_string_literal: true

module SGH
  module Elternverteiler
    # Zeitraum, in der eine Erziehungsberechtigter ein Amt inne hat, z.B. als
    # Elternvertreter einer Klasse
    class Amtsperiode < Sequel::Model(:amtsperioden)
      include FormeHelper

      many_to_one :inhaber, class: Erziehungsberechtigter
      many_to_one :amt
      many_to_one :klasse

      def to_s
        [amt, klasse].join(' ') << ": #{inhaber}"
      end
    end
  end
end
