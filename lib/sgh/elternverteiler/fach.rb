# frozen_string_literal: true

module SGH
  module Elternverteiler
    class Fach < Sequel::Model(:fächer)
      include FormeHelper

      many_to_many :lehrer,
        class: Lehrer,
        join_table: :unterrichtet,
        left_key: :fach_id,
        right_key: :lehrer_id

      def <=>(other)
        name <=> other.name
      end

      alias_method :to_s, :name
    end
  end
end
