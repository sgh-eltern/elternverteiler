# frozen_string_literal: true

module SGH
  module Elternverteiler
    class FachMapper
      def map(*kürzel)
        kürzel.map do |k|
          Fach.find_or_create(
            kürzel: k,
            name: name(k)
          )
        end
      end

      private

      def name(kürzel)
        {
          'BK' => 'Bildende Kunst',
          'Bio' => 'Biologie',
          'Ch' => 'Chemie',
          'D' => 'Deutsch',
          'E' => 'Englisch',
          'Eth' => 'Ethik',
          'F' => 'Französisch',
          'G' => 'Geschichte',
          'Geo' => 'Geografie',
          'Gk' => 'Gemeinschaftskunde',
          'L' => 'Latein',
          'M' => 'Mathematik',
          'Mu' => 'Musik',
          'NwT' => 'Naturwissenschaft und Technik',
          'Ph' => 'Physik',
          'Rev' => 'Evangelische Religionslehre',
          'Rrk' => 'Katholische Religionslehre',
          'Sm' => 'Sport männlich',
          'Sp' => 'Spanisch',
          'Sw' => 'Sport weiblich',
        }.fetch(kürzel, kürzel)
      end
    end
  end
end
