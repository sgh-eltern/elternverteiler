# frozen_string_literal: true

module SGH
  module Elternverteiler
    class Erziehungsberechtigung < Sequel::Model(:erziehungsberechtigung)
      include FormeHelper

      many_to_one :schüler, class: Schüler
      many_to_one :erziehungsberechtigter
    end
  end
end
