$LOAD_PATH.unshift File.join(__dir__, 'lib')
require 'sgh/elternverteiler/web/app'
run SGH::Elternverteiler::Web::App.freeze.app
