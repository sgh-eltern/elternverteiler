# frozen_string_literal: true

module SGH
  module Elternverteiler
    class KlassePresenter
      def initialize(grade, address)
        @grade = grade
        @address = address
      end

      def to_s
        pupils_in_grade = Schüler.where(klasse: @grade)
        return '' if pupils_in_grade.empty?
        parents_in_grade = pupils_in_grade.collect(&:eltern).flatten.uniq
        return '' if parents_in_grade.empty?
        "#{@address} #{parents_in_grade.map(&:mail).compact.join(',')}"
      end
    end
  end
end
