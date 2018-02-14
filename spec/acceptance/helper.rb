# frozen_string_literal: true

require 'capybara/rspec'

require 'sequel'
Sequel::Model.db = Sequel.connect(ENV.fetch('DB'))

Capybara.default_driver = :selenium_chrome # TODO: _headless

require 'sgh/elternverteiler/web/app'
Capybara.app = SGH::Elternverteiler::Web::App
