# frozen_string_literal: true

require 'sgh/elternverteiler/lehrer-diff/updater'

module SGH
  module Elternverteiler
    # Don't forget to restart the que process after this file was changed.
    class UpdateLehrerJob < Que::Job
      self.queue = 'lehrer'

      def run
        LehrerDiff::Updater.new.call
        finish
      end
    end
  end
end
