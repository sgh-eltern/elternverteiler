# frozen_string_literal: true

require 'roda'
require 'tilt'

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
            'elternbeirat': 'Elternbeirat',
            'elternbeirat/anwesenheit': '&nbsp;Anwesenheitsliste',
            'elternbeirat/klassen': '&nbsp;nach Klasse',
            'elternbeirat/vorsitzende': '&nbsp;Vorsitzende',
            'elternbeirat/schulkonferenz': '&nbsp;Schulkonferenz',
            'eltern': 'Alle Eltern',
            'schueler': 'Schüler',
            'schueler/nicht-erreichbar': '&nbsp;Nicht erreichbar',
          }

          r.root do
            @topic = 'Elternverteiler'
            schueler_unreachable_total = schueler_unreachable.count

            view 'home', locals: {
              eltern_total: Erziehungsberechtigter.count,
              schueler_total: Schüler.count,
              schueler_unreachable_total: schueler_unreachable_total,
              schueler_unreachable_percent: schueler_unreachable_total.to_f / Schüler.count * 100,
            }
          end

          r.on 'elternbeirat' do
            elternbeirat = Rolle.where(name: '1.EV').or(name: '2.EV').map(&:mitglieder).flatten.sort_by(&:nachname)

            r.on 'klassen' do
              @topic = 'Elternbeiräte der Klassen'
              view 'klassen', locals: { klassen: Klasse.all }
            end

            r.on 'anwesenheit' do
              @topic = 'Anwesenheitsliste'
              view 'anwesenheit', locals: { eltern: elternbeirat }
            end

            r.on 'vorsitzende' do
              @topic = 'Elternbeiratsvorsitzende'
              view 'eltern', locals: {
                eltern: Rolle.where(name: '1.EBV').or(name: '2.EBV').map(&:mitglieder).flatten
              }
            end

            r.on 'schulkonferenz' do
              @topic = 'Elternvertreter in der Schulkonferenz'
              evsk  = SGH::Elternverteiler::Rolle.where(name: 'SK').map(&:mitglieder).flatten
              evsk += SGH::Elternverteiler::Rolle.where(name: '1.EBV').map(&:mitglieder).flatten
              evsk.uniq!

              view 'eltern', locals: { eltern: evsk.sort_by(&:nachname) }
            end

            r.on do
              @topic = "Alle #{elternbeirat.count} Elternbeiräte"
              view 'eltern', locals: { eltern: elternbeirat }
            end
          end

          r.on 'eltern' do
            @topic = "Alle #{Erziehungsberechtigter.count} Eltern"
            view 'eltern', locals: { eltern: Erziehungsberechtigter.order(:nachname) }
          end

          r.on 'schueler' do
            r.on 'nicht-erreichbar' do
              schueler = schueler_unreachable
              @topic = "#{schueler.count} nicht per eMail erreichbare Schüler"
              view 'schueler', locals: { schueler: schueler }
            end

            r.on do
              @topic = "Alle #{Schüler.count} Schüler"
              view 'schueler', locals: { schueler: Schüler.order(:nachname) }
            end
          end
        end
        # rubocop:enable Metrics/BlockLength

        def schueler_unreachable
          Schüler.all.select { |sch| sch.eltern.collect(&:mail).compact.empty? }
        end
      end
    end
  end
end
