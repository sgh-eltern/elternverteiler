# frozen_string_literal: true

module SGH
  module Elternverteiler
    class Schüler < Sequel::Model(:schüler)
      many_to_many :eltern,
        left_key: :schüler_id,
        right_key: :erziehungsberechtigter_id,
        join_table: :erziehungsberechtigung,
        class: Erziehungsberechtigter
    end
  end
end
