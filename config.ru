# frozen_string_literal: true

$LOAD_PATH.unshift File.join(__dir__, 'lib')

require 'sequel'
Sequel::Model.db = Sequel.connect(ENV.fetch('DB'))

require 'sgh/elternverteiler/web/app'
run SGH::Elternverteiler::Web::App.freeze.app