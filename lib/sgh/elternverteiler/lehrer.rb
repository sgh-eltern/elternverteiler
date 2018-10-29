# frozen_string_literal: true

module SGH
  module Elternverteiler
    Lehrer = Struct.new(:kürzel, :titel, :nachname, :vorname, :fächer, :email, keyword_init: true) do
      def to_s
        if titel
          "#{titel} #{nachname}, #{vorname} <#{email}>"
        else
          "#{nachname}, #{vorname} <#{email}>"
        end
      end

      def <=>(other)
        [nachname, vorname] <=> [other.nachname, other.vorname]
      end
    end
  end
end
