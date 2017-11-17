# frozen_string_literal: true

module SGH
  module Elternverteiler
    class Erziehungsberechtigter < Sequel::Model(:erziehungsberechtigte)
      many_to_many :kinder,
        left_key: :erziehungsberechtigter_id,
        right_key: :schüler_id,
        join_table: :erziehungsberechtigung,
        class: Schüler
    end
  end
end
