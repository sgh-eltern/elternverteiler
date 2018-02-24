# frozen_string_literal: true

module SGH
  module Elternverteiler
    module FormeHelper
      def forme_namespace
        self.class.name.downcase.gsub('::', '-')
      end
    end
  end
end
