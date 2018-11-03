$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require 'sequel'
Sequel::Model.db = Sequel.connect(ENV.fetch('DB'))

require 'sgh/elternverteiler'

# rubocop:disable Style/MixinUsage
include SGH::Elternverteiler
# rubocop:enable Style/MixinUsage

require 'que'
Que.connection = Sequel::Model.db
