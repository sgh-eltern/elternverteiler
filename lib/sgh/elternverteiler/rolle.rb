# frozen_string_literal: true

module SGH
  module Elternverteiler
    class Rolle < Sequel::Model(:rollen)
      many_to_many :mitglieder,
        class: :Erziehungsberechtigter,
        join_table: :erziehungsberechtigte_rollen,
        left_key: :rolle_id,
        right_key: :erziehungsberechtigter_id
    end
  end
end
