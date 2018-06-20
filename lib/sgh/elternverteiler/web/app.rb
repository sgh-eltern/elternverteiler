# frozen_string_literal: true

require 'roda'
require 'forme'
require 'English'
require 'hashdiff'

require 'sgh/elternverteiler'
require 'sgh/elternverteiler/postmap_presenter'
require 'sgh/elternverteiler/postmap_parser'
require 'sgh/elternverteiler/recovery'
require 'sgh/elternverteiler/mail_server'
require 'sgh/elternverteiler/mailing_list'

module SGH
  module Elternverteiler
    module Web
      class App < Roda
        use Rack::Session::Cookie, secret: ENV.fetch('SESSION_SECRET')

        plugin :error_handler
        plugin :flash
        plugin :forme
        plugin :h
        plugin :partials
        plugin :render, escape: true
        plugin :render_each
        plugin :request_headers
        plugin :static, ['/js', '/css']
        plugin :status_handler
        Sequel::Model.plugin :forme

        status_handler(404) do
          topic 'Nicht gefunden'
          view :not_found
        end

        # rubocop:disable Metrics/BlockLength
        route do |r|
          title 'Elternbeirat am SGH'
          @menu = {
            '/elternbeirat': 'Elternbeirat',
            '/elternbeirat/anwesenheit': '&nbsp;Anwesenheit',
            '/elternbeirat/klassen': '&nbsp;nach Klassen',
            '/elternbeirat/schulkonferenz': '&nbsp;Schulkonferenz',
            '/elternbeirat/vorsitzende': '&nbsp;Vorsitzende',

            '/eltern': 'Eltern',

            '/schueler': 'Schüler',
            '/schueler/nicht-erreichbar': '&nbsp;Nicht erreichbar',

            '/klassen': 'Klassen',
            '/rollen': 'Rollen',
            '/backups': 'Backups',
            '/backups/new': '&nbsp;Neu',

            '/verteiler': 'Verteiler',
            # '/verteiler/klassen': '&nbsp;Eltern',
            # '/verteiler/klassenstufen': '&nbsp;Klassenstufen',
            # '/verteiler/eltern': '&nbsp;Alle Eltern',
            # '/verteiler/elternbeirat': '&nbsp;Elternbeirat',
          }
          @current_path = r.path
          @user = r.headers['Multipass-Handle']

          r.root do
            topic 'Übersicht'
            view :home
          end

          r.on 'elternbeirat' do
            r.on 'anwesenheit' do
              topic 'Anwesenheit'
              @email = 'elternbeirat@schickhardt-gymnasium-herrenberg.de'
              @eltern = elternbeirat

              view :anwesenheit
            end

            r.on 'klassen' do
              topic 'Elternvertreter der Klassen'
              @klassen_ämter = Klasse.sort.map do |klasse|
                [
                  klasse,
                  Amt.where(
                    rolle: Rolle.where(Sequel.like(:name, '%.EV')), klasse: klasse
                    ).sort_by(&:to_s)
                ]
              end
              view 'elternvertreter/klassen'
            end

            r.on 'schulkonferenz' do
              topic 'Elternvertreter in der Schulkonferenz'
              @email = 'elternvertreter-schulkonferenz@schickhardt-gymnasium-herrenberg.de'

              # BUG: The spreadsheet requires the 1.EBV to be marked as SK, too, so we get a duplicate.
              @eltern = evsk
              view 'erziehungsberechtigter/list'
            end

            r.on 'vorsitzende' do
              topic 'Vorsitzende'
              @email = 'elternbeiratsvorsitzende@schickhardt-gymnasium-herrenberg.de'
              @eltern = ebv
              view 'erziehungsberechtigter/list'
            end

            r.on do
              topic 'Alle Elternvertreter'
              @email = 'elternbeirat@schickhardt-gymnasium-herrenberg.de'
              @eltern = elternbeirat
              view 'erziehungsberechtigter/list'
            end
          end

          r.on 'eltern' do
            r.get 'neu' do |id|
              topic 'Erziehungsberechtigten hinzufügen'
              @erziehungsberechtigter = Erziehungsberechtigter.new
              view 'erziehungsberechtigter/new'
            end

            r.get Integer do |id|
              @erziehungsberechtigter = Erziehungsberechtigter.first!(id: id)
              topic 'Erziehungsberechtigte/r'
              view 'erziehungsberechtigter/show'
            end

            r.post Integer, 'delete' do |id|
              @erziehungsberechtigter = Erziehungsberechtigter.first!(id: id).destroy
              flash[:success] = "#{@erziehungsberechtigter} wurde gelöscht."
              r.redirect '/eltern'
            end

            r.get Integer, 'edit' do |id|
              @erziehungsberechtigter = Erziehungsberechtigter.first!(id: id)
              topic 'Eltern bearbeiten'
              view 'erziehungsberechtigter/edit'
            end

            r.post Integer do |id|
              @erziehungsberechtigter = Erziehungsberechtigter.first!(id: id)
              @erziehungsberechtigter.set_fields(r.params['sgh-elternverteiler-erziehungsberechtigter'], %w[vorname nachname mail telefon])
              @erziehungsberechtigter.save
              flash[:success] = 'Erziehungsberechtigter wurde aktualisiert'
              r.redirect
            rescue SGH::Elternverteiler::Erziehungsberechtigter::ValidationError
              topic 'Eltern bearbeiten'
              flash.now[:error] = $ERROR_INFO.message
              view 'erziehungsberechtigter/edit'
            end

            r.post do
              @erziehungsberechtigter = Erziehungsberechtigter.new
              @erziehungsberechtigter.set_fields(r.params['sgh-elternverteiler-erziehungsberechtigter'], %w[vorname nachname mail telefon])
              @erziehungsberechtigter.save
              r.redirect "/eltern/#{@erziehungsberechtigter.id}"
            rescue SGH::Elternverteiler::Erziehungsberechtigter::ValidationError
              topic 'Erziehungsberechtigten hinzufügen'
              flash.now[:error] = $ERROR_INFO.message
              view 'erziehungsberechtigter/new'
            end

            r.on do
              topic 'Alle Eltern'
              @email = 'eltern@schickhardt-gymnasium-herrenberg.de'
              @eltern = eltern
              view 'erziehungsberechtigter/list'
            end
          end

          r.on 'klassen' do
            r.get 'neu' do |id|
              topic 'Neue Klasse anlegen'
              @klasse = Klasse.new
              view 'klassen/new'
            end

            r.get Integer do |id|
              @klasse = Klasse.first!(id: id)
              @schüler = @klasse.schüler
              topic "Klasse #{@klasse}"
              @ämter = Amt.where(
                rolle: Rolle.where(Sequel.like(:name, '%.EV')), klasse: @klasse
                ).sort_by(&:to_s)
              @email = "elternvertreter-#{@klasse.to_s.downcase}@schickhardt-gymnasium-herrenberg.de"
              view 'schüler/list'
            end

            r.get Integer, 'rollen', 'add' do |klasse_id|
              topic 'Neuer Amtsinhaber'
              klasse = Klasse.first!(id: klasse_id)
              @amt = Amt.new(klasse: klasse)
              view 'elternvertreter/add'
            end

            r.post Integer, 'rollen', 'add' do |klasse_id|
              klasse = Klasse.first!(id: klasse_id)
              rolle = Rolle.first!(id: r.params['sgh-elternverteiler-amt']['rolle_id'])
              inhaber = Erziehungsberechtigter.first!(id: r.params['sgh-elternverteiler-amt']['inhaber_id'])
              Amt.new(klasse: klasse, rolle: rolle, inhaber: inhaber).save
              flash[:success] = "#{inhaber} ist jetzt #{rolle} in der #{klasse}"
              r.redirect "/klassen/#{klasse.id}"
            end

            r.post Integer, 'rollen', Integer, 'inhaber', Integer do |klasse_id, rolle_id, inhaber_id|
              topic 'Amtsinhaber löschen'
              klasse = Klasse.first!(id: klasse_id)
              rolle = Rolle.first!(id: rolle_id)
              inhaber = Erziehungsberechtigter.first!(id: inhaber_id)
              Amt.first!(klasse: klasse, rolle: rolle, inhaber: inhaber).destroy
              flash[:success] = "#{inhaber} ist nicht mehr #{rolle} in der #{klasse}."
              r.redirect "/klassen/#{klasse.id}"
            end

            r.post Integer, 'delete' do |id|
              @klasse = Klasse.first!(id: id)
              @klasse.destroy
              flash[:success] = "#{@klasse} wurde gelöscht."
              r.redirect '/klassen'
            rescue StandardError
              flash[:error] = "Die Klasse #{@klasse} hat Schüler und kann deshalb nicht gelöscht werden."
              r.redirect(r.referrer)
            end

            r.post Integer do |id|
              raise 'Missing implementation for editing Klasse'
            end

            r.post do
              @klasse = Klasse.new
              @klasse.set_fields(r.params['sgh-elternverteiler-klasse'], %w[stufe zug])
              @klasse.save
              r.redirect "/klassen/#{@klasse.id}"
            rescue Sequel::UniqueConstraintViolation
              topic 'Neue Klasse anlegen'
              flash.now[:error] = "Die Klasse #{@klasse.name} existiert bereits"
              view 'rollen/new'
            end

            r.on do
              topic 'Alle Klassen'
              view 'klassen/list'
            end
          end

          r.on 'rollen' do
            r.get 'neu' do |id|
              topic 'Neue Rolle anlegen'
              @rolle = Rolle.new
              view 'rollen/new'
            end

            r.get Integer do |id|
              @rolle = Rolle.first!(id: id)
              topic 'Rolle'
              view 'rollen/show'
            end

            r.post Integer, 'delete' do |id|
              @rolle = Rolle.first!(id: id).destroy
              flash[:success] = "Die Rolle #{@rolle} wurde gelöscht."
              r.redirect '/rollen'
            end

            r.post Integer do |id|
              raise 'Missing implementation for editing Rolle'
            end

            r.post do
              @rolle = Rolle.new
              @rolle.name = r.params['sgh-elternverteiler-rolle']['name']
              @rolle.save
              r.redirect "/rollen/#{@rolle.id}"
            rescue Sequel::UniqueConstraintViolation
              topic 'Neue Rolle anlegen'
              flash.now[:error] = "Die Rolle #{@rolle.name} existiert bereits"
              view 'rollen/new'
            end

            r.on do
              topic 'Alle Rollen'
              view 'rollen/list'
            end
          end

          r.on 'schueler' do
            r.get Integer do |id|
              @schüler = Schüler.first!(id: id)
              topic 'Schüler/in'
              view 'schüler/show'
            end

            r.get Integer, 'edit' do |id|
              @schüler = Schüler.first!(id: id)
              topic 'Schüler bearbeiten'
              view 'schüler/edit'
            end

            r.get Integer, 'erziehungsberechtigter', 'add' do |id|
              topic 'Erziehungsberechtigten zuweisen'
              @erziehungsberechtigung = Erziehungsberechtigung.new
              @erziehungsberechtigung.schüler = Schüler.first!(id: id)
              view 'schüler/assign_parent'
            end

            r.get 'neu' do |id|
              topic 'Schüler anlegen'
              @schüler = Schüler.new
              view 'schüler/new'
            end

            r.post Integer, 'delete' do |id|
              @schüler = Schüler.first!(id: id).destroy
              flash[:success] = "#{@schüler} wurde gelöscht."
              r.redirect '/schueler'
            end

            r.post Integer, 'erziehungsberechtigter', 'add' do |id|
              schüler = Schüler.first!(id: id)
              erziehungsberechtigter = Erziehungsberechtigter.first!(id: r.params['sgh-elternverteiler-erziehungsberechtigung']['erziehungsberechtigter_id'])
              Erziehungsberechtigung.new(schüler: schüler, erziehungsberechtigter: erziehungsberechtigter).save
              flash[:success] = "#{erziehungsberechtigter} ist jetzt als Erziehungsberechtigte(r) von #{schüler} registriert."
              r.redirect "/schueler/#{schüler.id}"
            end

            r.post Integer do |id|
              @schüler = Schüler.first!(id: id)
              @schüler.set_fields(r.params['sgh-elternverteiler-schüler'], %w[vorname nachname klasse_id])
              @schüler.save
              flash[:success] = 'Schüler wurde aktualisiert'
              r.redirect
            rescue Sequel::ConstraintViolation
              topic 'Schüler bearbeiten'
              flash.now[:error] = 'Alle Pflichtfelder müssen ausgefüllt werden.'
              view 'schüler/edit'
            end

            r.post do
              @schüler = Schüler.new
              @schüler.set_fields(r.params['sgh-elternverteiler-schüler'], %w[vorname nachname klasse_id])
              @schüler.save
              r.redirect "/schueler/#{@schüler.id}"
            rescue Sequel::ConstraintViolation
              topic 'Schüler anlegen'
              flash.now[:error] = 'Alle Pflichtfelder müssen ausgefüllt werden.'
              view 'schüler/new'
            end

            r.on 'nicht-erreichbar' do
              @schüler = schüler_unreachable
              topic "#{@schüler.count} nicht per eMail erreichbare Schüler"
              view 'schüler/list'
            end

            r.on do
              topic 'Alle Schüler'
              @schüler = Schüler.order(:nachname)
              view 'schüler/list'
            end
          end

          r.on 'backups' do
            @backup_manager = Recovery::Manager.new('backups', ENV.fetch('DB'))

            r.get 'new' do
              topic 'Neues Backup anlegen'
              @backup = Recovery::Backup.new
              view 'backups/new'
            end

            r.post 'restore' do
              topic 'Backup einspielen'
              name = r.params['sgh/elternverteiler/backups']

              if name.nil?
                flash[:warning] = 'Kein Backup ausgewählt'
                r.redirect
              end

              @backup_manager.restore(Recovery::Backup.new(name))
              flash[:success] = "Backup #{name} wurde eingespielt."
              r.redirect
            rescue Recovery::Manager::ExecutionError
              flash[:error] = "Backup #{name} konnte nicht eingespielt werden."
              warn "Command: #{$ERROR_INFO.command}"
              warn "STDOUT: #{$ERROR_INFO.stdout}"
              warn "STDERR: #{$ERROR_INFO.stderr}"
              r.redirect
            end

            r.post do
              @backup = Recovery::Backup.new(r.params['name'])
              @backup_manager.backup(@backup)
              flash[:success] = "Backup #{@backup.name} wurde angelegt."
              r.redirect
            rescue StandardError
              topic 'Neues Backup'
              flash.now[:error] = $ERROR_INFO.message
              view 'backups/new'
            end

            r.on do
              topic 'Verfügbare Backups'
              view 'backups/list'
            end
          end

          r.on 'verteiler' do
            r.post 'diff' do
              @distribution_list = r.params['distribution_list']
              parser = SGH::Elternverteiler::PostmapParser.new
              updated_distribution_list = parser.parse(@distribution_list)
              current = parser.parse(SGH::Elternverteiler::MailServer.new.download)
              @diff = HashDiff.diff(current, updated_distribution_list)

              topic 'Änderungen überprüfen'
              view 'verteiler/diff'
            end

            r.post 'upload' do
              distribution_list = r.params['distribution_list']
              SGH::Elternverteiler::MailServer.new.upload(distribution_list, 'elternverteiler-from-app.txt')
              flash[:success] = 'Verteiler wurde erfolgreich aktualisiert.'
              r.redirect '/verteiler'
            end

            r.on do
              topic 'eMail-Verteiler'
              view 'verteiler/show'
            end
          end
        end
        # rubocop:enable Metrics/BlockLength

        error do |e|
          topic 'Sorry'
          @error = e
          response.status = 500
          view 'error'
        end

        def ebv
          @ebv ||= Rolle.where(name: ['1.EBV', '2.EBV']).map(&:mitglieder).flatten.sort_by(&:nachname)
        end

        def evsk
          @evsk ||= Rolle.where(name: ['SK', 'SKV']).map(&:mitglieder).flatten.sort_by(&:nachname)
        end

        def elternbeirat
          @elternbeirat ||= Rolle.where(name: ['1.EV', '2.EV']).map(&:mitglieder).flatten.sort_by(&:nachname)
        end

        def eltern
          @eltern ||= Erziehungsberechtigter.order(:nachname)
        end

        def klassen
          @klassen ||= Klasse.sort
        end

        def rollen
          @rollen ||= Rolle.sort
        end

        def eltern_total
          @eltern_total ||= Erziehungsberechtigter.count
        end

        # rubocop:disable Naming/MethodName
        def schüler_unreachable
          @schüler_unreachable ||= Schüler.all.select { |sch| sch.eltern.collect(&:mail).compact.empty? }.sort_by(&:nachname)
        end

        def schüler_unreachable_total
          @schüler_unreachable_total ||= schüler_unreachable.count
        end

        def schüler_total
          @schüler_total ||= Schüler.count
        end

        def schüler_unreachable_percent
          @schüler_unreachable_percent ||=
            if schüler_total.zero?
              0
            else
              schüler_unreachable_total.to_f / schüler_total * 100
            end
        end
        # rubocop:enable Naming/MethodName

        def title(title=nil)
          if title
            @title = title
          else
            @title
          end
        end

        def topic(topic=nil)
          if topic
            @topic = topic
          else
            @topic
          end
        end
      end
    end
  end
end
