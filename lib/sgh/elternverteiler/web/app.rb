# frozen_string_literal: true

require 'roda'
require 'forme'
require 'English'
require 'hashdiff'
require 'google/cloud/storage'

require 'sgh/elternverteiler'
require 'sgh/elternverteiler/postmap_presenter'
require 'sgh/elternverteiler/postmap_parser'
require 'sgh/elternverteiler/recovery'
require 'sgh/elternverteiler/mail_server'
require 'sgh/elternverteiler/mailing_list'

require 'sgh/elternverteiler/web/view_helpers'

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
        plugin :render_each
        plugin :request_headers
        plugin :empty_root
        plugin :static, ['/js', '/css']
        Sequel::Model.plugin :forme

        plugin :status_handler
        status_handler(404) do
          topic 'Nicht gefunden'
          view :not_found
        end

        plugin :error_handler do |e|
          topic 'Sorry'
          @error = e
          response.status = 500
          view 'error'
        end

        include SGH::Elternverteiler::Web::PathHelpers

        # rubocop:disable Metrics/BlockLength
        route do |r|
          title 'Elternbeirat am SGH'
          @menu = {
            '/elternbeirat': 'Elternbeirat',
            '/elternbeirat/anwesenheit': '&nbsp;&nbsp;Anwesenheit',
            '/elternbeirat/klassen': '&nbsp;&nbsp;nach Klassen',

            # TODO: Should be /elternbeirat/ämter
            '/ämter': '&nbsp;&nbsp;Ämter',

            '/klassenstufen': 'Klassenstufen',
            '/klassen': 'Klassen',
            '/schüler': 'Schüler',
            '/schüler/nicht-erreichbar': '&nbsp;&nbsp;Nicht erreichbar',
            '/eltern': 'Eltern',

            '/backups': 'Backups',
            '/backups/new': '&nbsp;&nbsp;Neu',

            '/verteiler': 'Verteiler',
            '/verteiler/export': '&nbsp;&nbsp;Plain',
            # TODO: New views
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
              view :anwesenheit
            end

            r.on 'klassen' do
              topic 'Elternvertreter der Klassen'
              @klassen_amtsperioden = klassen.map do |klasse|
                [
                  klasse,
                  Amtsperiode.where(
                    amt: Amt.where(Sequel.like(:name, '%.EV')), klasse: klasse
                    ).sort_by(&:to_s)
                ]
              end
              view 'elternvertreter/klassen'
            end

            r.on do
              topic 'Alle Elternvertreter'
              @eltern = elternbeirat
              view 'erziehungsberechtigter/list'
            end
          end

          r.on 'eltern' do
            r.root do
              topic 'Alle Eltern'
              @eltern = eltern.sort!
              view 'erziehungsberechtigter/list'
            end

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
          end

          r.on 'klassenstufen' do
            r.root do
              topic 'Alle Klassenstufen'
              view 'klassenstufen/list'
            end

            r.get 'neu' do |id|
              topic 'Neue Klassenstufe anlegen'
              @klassenstufe = Klassenstufe.new
              view 'klassenstufen/new'
            end

            r.get Integer do |id|
              @klassenstufe = Klassenstufe.first!(id: id)
              topic @klassenstufe
              view 'klassenstufen/show'
            end

            r.post Integer, 'delete' do |id|
              @klassenstufe = Klassenstufe.first!(id: id)
              @klassenstufe.destroy
              flash[:success] = "#{@klassenstufe} wurde gelöscht."
              r.redirect '/klassenstufen'
            rescue StandardError
              flash[:error] = "Die #{@klassenstufe} hat Klassen und kann deshalb nicht gelöscht werden."
              r.redirect(r.referrer)
            end

            r.post do
              @klassenstufe = Klassenstufe.new
              @klassenstufe.set_fields(r.params['sgh-elternverteiler-klassenstufe'], %w[name])
              @klassenstufe.save
              r.redirect "/klassenstufen/#{@klassenstufe.id}"
            rescue Sequel::UniqueConstraintViolation
              topic 'Neue Klassenstufe anlegen'
              flash.now[:error] = "Die #{@klassenstufe} existiert bereits"
              view 'klassenstufen/new'
            end
          end

          r.on 'klassen' do
            # /klassen/j1 or /klassen/7c
            r.on [/(j[12])/, /(\d{1,2})([a-z])/] do |st, zg|
              stufe = Klassenstufe.first!(name: st.upcase)
              @klasse = Klasse.first!(stufe: stufe, zug: zg ? zg.upcase : '')

              r.root do
                @schüler = @klasse.schüler.sort
                @amtsperioden = Amtsperiode.where(
                  amt: Amt.where(Sequel.like(:name, '%.EV')),
                  klasse: @klasse
                  ).sort_by(&:to_s)
                topic @klasse
                view 'klassen/show'
              end

              r.get CGI.escape('ämter'), 'add' do |klasse_id|
                topic "Neue Amtsperiode in der #{@klasse}"
                @amtsperiode = Amtsperiode.new(klasse: @klasse)
                view 'elternvertreter/add'
              end

              r.post CGI.escape('ämter'), 'add' do
                amt = Amt.first!(id: r.params['sgh-elternverteiler-amtsperiode']['amt_id'])
                inhaber = Erziehungsberechtigter.first!(id: r.params['sgh-elternverteiler-amtsperiode']['inhaber_id'])
                Amtsperiode.new(klasse: @klasse, amt: amt, inhaber: inhaber).save
                flash[:success] = "#{inhaber} ist jetzt #{amt} in der #{@klasse}"
                r.redirect(klasse_path(@klasse))
              end

              r.post CGI.escape('ämter'), Integer, 'inhaber', Integer do |amt_id, inhaber_id|
                topic 'Amtsperiode löschen'
                amt = Amt.first!(id: amt_id)
                inhaber = Erziehungsberechtigter.first!(id: inhaber_id)
                Amtsperiode.first!(klasse: @klasse, amt: amt, inhaber: inhaber).destroy
                flash[:success] = "#{inhaber} ist nicht mehr #{amt} in der #{@klasse}."
                r.redirect(klasse_path(@klasse))
              end

              r.post 'delete' do
                @klasse.destroy
                flash[:success] = "#{@klasse} wurde gelöscht."
                r.redirect '/klassen'
              end

              r.post do
                raise "Missing implementation for editing #{@klasse}"
              end
            rescue Sequel::NoMatchingRow
              flash.now[:error] = "Es gibt keine Klasse #{st}#{zg}"
              response.status = 404
              topic 'Klasse nicht gefunden'
              view 'klassen/not_found'
            end

            r.get 'neu' do
              topic 'Neue Klasse anlegen'
              @klasse = Klasse.new
              view 'klassen/new'
            end

            r.post do
              @klasse = Klasse.new
              @klasse.set_fields(r.params['sgh-elternverteiler-klasse'], %w[stufe_id zug])
              @klasse.save
              r.redirect(klasse_path(@klasse))
            rescue Sequel::UniqueConstraintViolation
              topic 'Neue Klasse anlegen'
              flash.now[:error] = "Die #{@klasse} existiert bereits"
              view 'klassen/new'
            rescue Sequel::ValidationFailed
              topic 'Neue Klasse anlegen'
              flash.now[:error] = 'Validierung fehlgeschlagen'
              view 'klassen/new'
            end

            r.root do
              topic 'Alle Klassen'
              view 'klassen/list'
            end
          end

          r.on CGI.escape('ämter') do
            r.get 'neu' do |id|
              topic 'Neue Amt anlegen'
              @amt = Amt.new
              view 'ämter/new'
            end

            r.get Integer do |id|
              @amt = Amt.first!(id: id)
              topic 'Amt'
              view 'ämter/show'
            end

            r.post Integer, 'delete' do |id|
              @amt = Amt.first!(id: id).destroy
              flash[:success] = "Das Amt #{@amt} wurde gelöscht."
              r.redirect '/ämter'
            end

            r.post Integer do |id|
              raise 'Missing implementation for editing Amt'
            end

            r.post do
              @amt = Amt.new
              @amt.name = r.params['sgh-elternverteiler-amt']['name']
              @amt.save
              r.redirect "/ämter/#{@amt.id}"
            rescue Sequel::UniqueConstraintViolation
              topic 'Neue Amt anlegen'
              flash.now[:error] = "Das Amt #{@amt.name} existiert bereits"
              view 'ämter/new'
            end

            r.on do
              topic 'Alle Ämter'
              view 'ämter/list'
            end
          end

          r.on CGI.escape('schüler') do
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
              r.redirect '/schüler'
            end

            r.post Integer, 'erziehungsberechtigter', 'add' do |id|
              schüler = Schüler.first!(id: id)
              erziehungsberechtigter = Erziehungsberechtigter.first!(id: r.params['sgh-elternverteiler-erziehungsberechtigung']['erziehungsberechtigter_id'])
              Erziehungsberechtigung.new(schüler: schüler, erziehungsberechtigter: erziehungsberechtigter).save
              flash[:success] = "#{erziehungsberechtigter} ist jetzt als Erziehungsberechtigte(r) von #{schüler} registriert."
              r.redirect "/schüler/#{schüler.id}"
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
              r.redirect "/schüler/#{@schüler.id}"
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
            @backup_manager = Recovery::BlobstoreManager.new(blobstore, ENV.fetch('DB'))

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

              @backup_manager.restore(Recovery::Backup.new(name: name))
              flash[:success] = "Backup #{name} wurde eingespielt."
              r.redirect
            rescue Recovery::ExecutionError
              flash[:error] = "Backup #{name} konnte nicht eingespielt werden."
              warn "Command: #{$ERROR_INFO.command}"
              warn "STDOUT: #{$ERROR_INFO.stdout}"
              warn "STDERR: #{$ERROR_INFO.stderr}"
              r.redirect
            end

            r.post do
              @backup = Recovery::Backup.new(name: r.params['name'])
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
            r.get 'export' do
              response['Content-Type'] = 'text/plain; charset=utf-8'
              render 'verteiler/_distribution_list'
            end

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
              SGH::Elternverteiler::MailServer.new.upload(distribution_list, 'elternverteiler.txt')
              flash[:success] = 'Verteiler wurde erfolgreich aktualisiert.'
              r.redirect '/verteiler'
            end

            r.on do
              topic 'eMail-Verteiler'
              view 'verteiler/all'
            end
          end
        end
        # rubocop:enable Metrics/BlockLength

        def ebv
          @ebv ||= SGH::Elternverteiler.elternbeiratsvorsitzende
        end

        def evsk
          @evsk ||= SGH::Elternverteiler.elternvertreter_schulkonferenz
        end

        def elternbeirat
          @elternbeirat ||= SGH::Elternverteiler.elternbeirat
        end

        def eltern
          @eltern ||= SGH::Elternverteiler::Erziehungsberechtigter.all
        end

        def klassenstufen
          @klassenstufen ||= SGH::Elternverteiler::Klassenstufe.sort
        end

        def klassen
          @klassen ||= Klasse.sort
        end

        def eltern_total
          @eltern_total ||= Erziehungsberechtigter.count
        end

        # rubocop:disable Naming/MethodName
        def ämter
          @ämter ||= Amt.sort
        end

        def schüler_unreachable
          @schüler_unreachable ||= Schüler.all.select { |sch| sch.eltern.collect(&:mail).compact.reject(&:empty?).empty? }.sort_by(&:nachname)
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

        def blobstore
          @blobstore ||= Google::Cloud::Storage.new(
            # Credentials are read from ENV['STORAGE_KEYFILE_JSON']
            project_id: 'sgh-elternbeirat'
          ).bucket('sgh-elternbeirat-app-backup')
        end
      end
    end
  end
end
