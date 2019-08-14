# frozen_string_literal: true

module SGH
  module Elternverteiler
    module LehrerDiff
      class LehrerPresenter
        def initialize(teacher)
          @teacher = teacher
        end

        def to_s
          "#{@teacher[:nachname]}, #{@teacher[:vorname]} (#{@teacher[:fächer].join(', ')})"
        end
      end
    end
  end
end
