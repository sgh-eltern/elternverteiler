# frozen_string_literal: true

require 'sequel'

Sequel::Model.plugin :timestamps

module SGH
  module Elternverteiler
    class Schüler < Sequel::Model(:schüler); end
    class Erziehungsberechtigter < Sequel::Model(:erziehungsberechtigte); end
    class Erziehungsberechtigung < Sequel::Model(:erziehungsberechtigung); end
  end
end

require 'sgh/elternverteiler/schüler'
require 'sgh/elternverteiler/erziehungsberechtigung'
require 'sgh/elternverteiler/erziehungsberechtigter'
