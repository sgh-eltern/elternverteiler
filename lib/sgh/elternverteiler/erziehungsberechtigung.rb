# frozen_string_literal: true

module SGH
  module Elternverteiler
    class Erziehungsberechtigung < Sequel::Model(:erziehungsberechtigung)
      many_to_one :kind
      many_to_one :erziehungsberechtigter
    end
  end
end
