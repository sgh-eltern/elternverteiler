# frozen_string_literal: true

require 'roda'
require 'tilt'
require 'forme'

require 'sgh/elternverteiler'
require 'sgh/elternverteiler/postmap_presenter'

module SGH
  module Elternverteiler
    module Web
      class App < Roda
        use Rack::Session::Cookie, secret: ENV.fetch('SESSION_SECRET')

        plugin :flash
        plugin :forme
        plugin :h
        plugin :partials
        plugin :render, escape: true
        plugin :static, ['/js', '/css']
        # TODO: plugin :csrf

        Sequel::Model.plugin :forme

        # rubocop:disable Metrics/BlockLength
        route do |r|
          @title = 'Elternbeirat am SGH'
          @menu = {
            '/elternvertreter': 'Elternvertreter',
            '/elternvertreter/klassen': '&nbsp;nach Klasse',

            '/elternbeirat': 'Elternbeirat',
            '/elternbeirat/vorsitzende': '&nbsp;Vorsitzende',
            '/elternbeirat/schulkonferenz': '&nbsp;Schulkonferenz',

            '/eltern': 'Eltern',

            '/schueler': 'Schüler',
            '/schueler/nicht-erreichbar': '&nbsp;Nicht erreichbar',

            '/klassen': 'Klassen',
          }
          @current_path = r.path
          @elternbeirat = Rolle.where(name: '1.EV').or(name: '2.EV').map(&:mitglieder).flatten.sort_by(&:nachname)

          r.root do
            @topic = 'Übersicht'
            schueler_unreachable_total = schueler_unreachable.count
            @eltern_total = Erziehungsberechtigter.count
            @schueler_total = Schüler.count
            @schueler_unreachable_total = schueler_unreachable_total
            @schueler_unreachable_percent = schueler_unreachable_total.to_f / Schüler.count * 100
            view :home
          end

          r.on 'elternvertreter' do
            r.on 'klassen' do
              @topic = 'Elternvertreter nach Klasse'
              @klassen_ämter = Klasse.map do |klasse|
                [
                  klasse,
                  Amt.where(
                    rolle: Rolle.where(Sequel.like(:name, '%.EV')), klasse: klasse
                    ).sort_by(&:to_s)
                ]
              end
              view 'elternvertreter/klassen'
            end

            r.on do
              @topic = 'Alle Elternvertreter'
              @email = 'elternbeirat@schickhardt-gymnasium-herrenberg.de'
              @eltern = @elternbeirat
              view :eltern
            end
          end

          r.on 'elternbeirat' do
            r.on 'vorsitzende' do
              @topic = 'Vorsitzende'
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
              @topic = 'Mitglieder'
              @email = 'elternbeirat@schickhardt-gymnasium-herrenberg.de'
              @eltern = @elternbeirat
              view :anwesenheit
            end
          end

          r.on 'eltern' do
            r.get Integer do |id|
              @erziehungsberechtigter = Erziehungsberechtigter.first!(id: id)
              @topic = "#{@erziehungsberechtigter.vorname} #{@erziehungsberechtigter.nachname}"
              view 'erziehungsberechtigter/show'
            end

            r.get Integer, 'edit' do |id|
              @erziehungsberechtigter = Erziehungsberechtigter.first!(id: id)
              @topic = "#{@erziehungsberechtigter.vorname} #{@erziehungsberechtigter.nachname}"
              view 'erziehungsberechtigter/edit'
            end

            r.post Integer do |id|
              @erziehungsberechtigter = Erziehungsberechtigter.first!(id: id)
              @erziehungsberechtigter.set_fields(r.params[@erziehungsberechtigter.forme_namespace], %w[vorname nachname mail telefon])
              @erziehungsberechtigter.save
              flash[:success] = 'Erziehungsberechtigter wurde aktualisiert'
              r.redirect
            end

            r.on do
              @topic = 'Alle Eltern'
              @email = 'eltern@schickhardt-gymnasium-herrenberg.de'
              @eltern = Erziehungsberechtigter.order(:nachname)
              view :eltern
            end
          end

          r.on 'klassen' do
            r.get Integer do |id|
              @schüler = Klasse.first!(id: id).schüler
              @topic = "Klasse #{@klasse}"
              view 'schüler/list'
            end

            r.on do
              @topic = 'Alle Klassen'
              @klassen = Klasse.all
              view 'klassen/list'
            end
          end

          r.on 'schueler' do
            r.get Integer do |id|
              @schüler = Schüler.first!(id: id)
              @topic = "#{@schüler.vorname} #{@schüler.nachname}"
              view 'schüler/show'
            end

            r.get Integer, 'edit' do |id|
              @schüler = Schüler.first!(id: id)
              @topic = "#{@schüler.vorname} #{@schüler.nachname}"
              view 'schüler/edit'
            end

            r.on 'nicht-erreichbar' do
              @schüler = schueler_unreachable
              @topic = "#{@schüler.count} nicht per eMail erreichbare Schüler"
              view 'schüler/list'
            end

            r.on do
              @topic = 'Alle Schüler'
              @schüler = Schüler.order(:nachname)
              view 'schüler/list'
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
