# frozen_string_literal: true

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

        # rubocop:disable Metrics/BlockLength
        route do |r|
          @title = 'Elternbeirat am SGH'
          @menu = {
            eltern: 'Alle Eltern',
            elternbeirat: 'Elternbeirat',
            elternbeiratsvorsitzende: 'Elternbeiratsvorsitzende',
            schulkonferenz: 'Schulkonferenz',
            klassen: 'Klassen',
          }

          r.root do
            @topic = 'Elternverteiler'
            schueler_unreachable_total = Schüler.all.select { |sch| sch.eltern.collect(&:mail).compact.empty? }.count

            view 'home', locals: {
              eltern_total: Erziehungsberechtigter.count,
              schueler_total: Schüler.count,
              schueler_unreachable_total: schueler_unreachable_total,
              schueler_unreachable_percent: schueler_unreachable_total.to_f / Schüler.count * 100,
            }
          end

          r.on 'klassen' do
            @topic = 'Elternbeiräte der Klassen'
            view 'klassen', locals: { klassen: Klasse.all }
          end

          r.on 'elternbeirat' do
            elternbeirat = Rolle.where(name: '1.EV').or(name: '2.EV').map(&:mitglieder).flatten.sort_by(&:nachname)
            @topic = "Alle #{elternbeirat.count} Elternbeiräte"
            view 'eltern', locals: { eltern: elternbeirat }
          end

          r.on 'elternbeiratsvorsitzende' do
            @topic = 'Elternbeiratsvorsitzende'
            view 'eltern', locals: {
              eltern: Rolle.where(name: '1.EBV').or(name: '2.EBV').map(&:mitglieder).flatten
            }
          end

          r.on 'eltern' do
            @topic = "Alle #{Erziehungsberechtigter.count} Eltern"
            view 'eltern', locals: { eltern: Erziehungsberechtigter.order(:nachname) }
          end

          r.on 'schulkonferenz' do
            @topic = 'Elternvertreter in der Schulkonferenz'
            evsk = SGH::Elternverteiler::Rolle.where(name: 'SK').map(&:mitglieder).flatten.sort_by(&:nachname)

            view 'eltern', locals: { eltern: evsk }
          end
        end
      end
    end
  end
end
