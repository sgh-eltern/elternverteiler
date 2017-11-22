# frozen_string_literal: true

module SGH
  module Elternverteiler
    class Erziehungsberechtigter < Sequel::Model(:erziehungsberechtigte)
      many_to_many :kinder,
        class: Schüler,
        join_table: :erziehungsberechtigung,
        left_key: :erziehungsberechtigter_id,
        right_key: :schüler_id

      many_to_many :rollen,
        class: Rolle,
        join_table: :erziehungsberechtigte_rollen,
        left_key: :erziehungsberechtigter_id,
        right_key: :rolle_id
    end
  end
end
