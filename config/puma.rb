# frozen_string_literal: true

root = "#{__dir__}/.."

pidfile "#{root}/var/puma.pid"
state_path "#{root}/var/puma.state"
rackup "#{root}/config.ru"
threads 4, 8
activate_control_app 'unix://var/puma-ctl.sock', { auth_token: ENV.fetch('puma_control_token') }
