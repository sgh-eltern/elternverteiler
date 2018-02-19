# frozen_string_literal: true

module SGH
  module Elternverteiler
    class Erziehungsberechtigung < Sequel::Model(:erziehungsberechtigung)
      many_to_one :schüler, class: Schüler
      many_to_one :erziehungsberechtigter

      def forme_namespace
        self.class.name.tr(':', '-')
      end
    end
  end
end
