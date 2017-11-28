require 'roda'
require 'tilt'

require 'sequel'
Sequel::Model.db = Sequel.connect(ENV.fetch('DB'))

require 'sgh/elternverteiler'
require 'sgh/elternverteiler/postmap_presenter'

module SGH
  module Elternverteiler
    module Web
      class App < Roda
        plugin :static, ['/js', '/css']
        plugin :render

        route do |r|
          @title = 'Elternbeirat am SGH'
          @menu = {
            elternbeirat: 'Elternbeirat',
            schulkonferenz: 'Schulkonferenz',
          }

          r.root do
            @topic = 'Elternverteiler'
            view 'eltern', locals: { eltern: [] }
          end

          r.on "elternbeirat" do
            @topic = 'Elternbeirat'
            view 'eltern', locals: { eltern: Erziehungsberechtigter.all }
          end

          r.on "schulkonferenz" do
            @topic = 'Elternvertreter in der Schulkonferenz'
            evsk = SGH::Elternverteiler::Rolle.where(name: 'SK').map(&:mitglieder).flatten
            view 'eltern', locals: { eltern: evsk }
          end
        end
      end
    end
  end
end
