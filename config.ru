# frozen_string_literal: true

$LOAD_PATH.unshift File.join(__dir__, 'lib')

require_relative 'config/db'
require_relative 'config/que'
require 'sgh/elternverteiler/web/app'

run SGH::Elternverteiler::Web::App.freeze.app
