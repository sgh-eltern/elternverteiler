# frozen_string_literal: true

module SGH
  module Elternverteiler
    class Wahl < Sequel::Model(:erziehungsberechtigte_rollen)
      many_to_one :erziehungsberechtigter
      many_to_one :rolle
      many_to_one :klasse
    end
  end
end
