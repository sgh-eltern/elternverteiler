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
        plugin :partials

        # rubocop:disable Metrics/BlockLength
        route do |r|
          @title = 'Elternbeirat am SGH'
          @menu = {
            '/elternbeirat': 'Elternbeirat',
            '/elternbeirat/anwesenheit': '&nbsp;Anwesenheitsliste',
            '/elternbeirat/klassen': '&nbsp;nach Klasse',
            '/elternbeirat/vorsitzende': '&nbsp;Vorsitzende',
            '/elternbeirat/schulkonferenz': '&nbsp;Schulkonferenz',
            '/eltern': 'Eltern',
            '/schueler': 'Schüler',
            '/schueler/nicht-erreichbar': '&nbsp;Nicht erreichbar',
          }
          @current_path = r.path

          r.root do
            @topic = 'Elternverteiler'
            schueler_unreachable_total = schueler_unreachable.count
            @eltern_total = Erziehungsberechtigter.count
            @schueler_total = Schüler.count
            @schueler_unreachable_total = schueler_unreachable_total
            @schueler_unreachable_percent = schueler_unreachable_total.to_f / Schüler.count * 100
            view :home
          end

          r.on 'elternbeirat' do
            elternbeirat = Rolle.where(name: '1.EV').or(name: '2.EV').map(&:mitglieder).flatten.sort_by(&:nachname)

            r.on 'klassen' do
              @topic = 'Elternbeiräte der Klassen'
              @klassen = Klasse.all
              view :klassen
            end

            r.on 'anwesenheit' do
              @topic = 'Anwesenheitsliste'
              @email = 'elternbeirat@schickhardt-gymnasium-herrenberg.de'
              @eltern = elternbeirat
              view :anwesenheit
            end

            r.on 'vorsitzende' do
              @topic = 'Elternbeiratsvorsitzende'
              @email = 'elternbeiratsvorsitzende@schickhardt-gymnasium-herrenberg.de'
              @eltern = Rolle.where(name: '1.EBV').or(name: '2.EBV').map(&:mitglieder).flatten
              view :eltern
            end

            r.on 'schulkonferenz' do
              @topic = 'Elternvertreter in der Schulkonferenz'
              @email = 'elternvertreter-schulkonferenz@schickhardt-gymnasium-herrenberg.de'

              evsk = SGH::Elternverteiler::Rolle.where(name: ['SK', '1.EBV']).flat_map(&:mitglieder)
              # BUG: The spreadsheet requires the 1.EBV to be marked as SK, too, so we get a duplicate.
              evsk.uniq!

              @eltern = evsk.sort_by(&:nachname)
              view :eltern
            end

            r.on do
              @topic = "Alle #{elternbeirat.count} Elternbeiräte"
              @email = 'elternbeirat@schickhardt-gymnasium-herrenberg.de'
              @eltern = elternbeirat
              view :eltern
            end
          end

          r.on 'eltern' do
            @topic = "Alle #{Erziehungsberechtigter.count} Eltern"
            @email = 'eltern@schickhardt-gymnasium-herrenberg.de'
            @eltern = Erziehungsberechtigter.order(:nachname)
            view :eltern
          end

          r.on 'schueler' do
            r.on 'nicht-erreichbar' do
              @schueler = schueler_unreachable
              @topic = "#{@schueler.count} nicht per eMail erreichbare Schüler"
              view :schueler
            end

            r.on do
              @topic = "Alle #{Schüler.count} Schüler"
              @schueler = Schüler.order(:nachname)
              view :schueler
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
