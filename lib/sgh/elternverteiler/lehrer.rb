# frozen_string_literal: true

require 'sgh/elternverteiler/fach'

=begin
BEWARE: The backups until at least 2018-11-05T18:48:29+00:00	have old tables
lehrer, fach etc. in there. They need to be dropped manually after restoring
those backups with:

  drop table fach;
  drop table fächer cascade;
  drop table lehrer cascade;
  drop table unterrichtet cascade;
=end

module SGH
  module Elternverteiler
    class Lehrer < Sequel::Model(:lehrer)
      include FormeHelper

      many_to_many :fächer,
        class: Fach,
        join_table: :unterrichtet,
        left_key: :lehrer_id,
        right_key: :fach_id

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

      alias :mail :email
    end
  end
end
