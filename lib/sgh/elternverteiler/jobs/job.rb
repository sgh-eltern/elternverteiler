# frozen_string_literal: true

require 'que'
require 'que/sequel/model'

module SGH
  module Elternverteiler
    class Job < Que::Sequel::Model; end
  end
end
