# frozen_string_literal: true

module SGH
  module Elternverteiler
    class Erziehungsberechtigter < Sequel::Model(:erziehungsberechtigte)
      many_to_many :kinder,
        join_table: :erziehungsberechtigung,
        left_key: :erziehungsberechtigter_id,
        right_key: :schüler_id,
        class: Schüler
    end
  end
end
