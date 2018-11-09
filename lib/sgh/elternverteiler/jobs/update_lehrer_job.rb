# frozen_string_literal: true

require 'sgh/elternverteiler/lehrer_updater'

module SGH
  module Elternverteiler
    # Don't forget to restart the que process after this file was changed.
    class UpdateLehrerJob < Que::Job
      self.queue = 'lehrer'

      def run
        LehrerUpdater.new.call
        finish
      end
    end
  end
end
