# Elternverteiler

Input für Elternverteiler der SGH. Wird von `cron` alle 5 min eingelesen und per `postmap elternverteiler.txt` in eine hash-DB für Postfix umgewandelt.

Ansprechpartner: ***REMOVED***

Hochladen:

```bash
scp elternverteiler.txt ***REMOVED***.schickhardt-gymnasium-herrenberg.de:
```

# Prioritäten

* vollständig
* handhabbar (verwaltbar) durch Nicht-Experten (sichert Überleben des Verteilers)
* Dienst am Elternvertreter
* Datenschutz (unter Kontrolle der Schule)

# Datenfluß

**Prinzip**: Schule muß _einem_ der Elternteile alle Information zukommen lassen.

## Schuljahresbeginn

* bei der Schulanmeldung stimmen alle Eltern zu, daß die eMail für schulische Zwecke verwendet werden darf
* ca. 1 Woche vor Schuljahresbeginn: ***REMOVED*** geht ins Sekretariat (Frau ***REMOVED***) und bekommt Name, Klasse und eMail auf USB (Excel)
  - J2 fällt raus (ca. 1 Woche vor Schuljahresbeginn löschen)
  - 5er kommen dazu
  - Großteil wird versetzt
* Ziel: in der zweiten Hälfte der letzten Ferienwoche soll der Verteiler stehen, damit die Informationen zum Schuljahresbeginn rechtzeitig ankommen
* Nach Fertigstellung Information an Schulleitung

## Änderungen unter dem Jahr

* Frau ***REMOVED*** bekommt die Informationen und schickt eine Mail
* Rückläufer kommen an Absender zurück, TODO besser wäre an mich
* Wie spricht man Frau ***REMOVED*** am besten an? eMail ok, aber TODO bald vorbeigehen. Telefon eher nicht.
* Bewußtsein zum Datenschutz liegt vor. 3-4 Adressen ist ok, mehr nicht.

## Ferien

* ***REMOVED*** hat den Verteiler bisher immer in den Ferien deaktiviert (es sollte Ruhe sein, kein SPAM)
  - mit Schule abgesprochen
  - Termin der Umschaltung an Schule kommunizieren
  - theoretischer Termin für den Klassenübergang ist der 31.7.
* J2er wollen nach Abitur möglichst sofort aus dem Verteiler raus

## Sonderfälle

* Manchmal wollen getrennte Eltern, daß der Partner nicht mehr im Verteiler steht
* **IMMER** über die Schule gehen
* handschriftliche Listen beim ersten Elternabend sind unnötig, aber die Schule will das wohl
* Es gibt auch Elternvertreter, die die Liste ablehnen und ihre eigenen Verteiler pflegen
* ***REMOVED*** ***REMOVED*** hatte Wurm, der Mails an den Elternverteiler verschickt hat
* Es gab auch schon eMail-"Schlachten"

# TODOs

* Kommunikation an die Eltern?
  - Nutzungsanleitung ging von ***REMOVED*** an ***REMOVED***. ***REMOVED*** schickt das mir nochmal.
  - TODO: auch an Lehrer geben (über ***REMOVED***)
* Was ist eltern-eia@schickhardt-gymnasium-herrenberg.de ***REMOVED***
  - für ***REMOVED*** ***REMOVED*** ("English in Action")
  - ist dieses Jahr nicht aktiv
* Wurde schonmal über Footer unter jeder Mail nachgedacht?
  - nein, aber sinnvoll TODO
* TODO Spreadsheet hat ***REMOVED*** in verschlüsseltem ZIP-File (Passwort: ***REMOVED***)
* keine Metriken erhoben (Bounces, Anzahl der zugestellten Mails, etc.)
* Farbenvorschlag:

    # grün
    00cc66

    # gelb
    FFFF00

    # rot
    FF3300

# Ausblick

* Verteiler sollte in Datenbank laufen
  - Reports, z.B. welche Schüler sind nicht im Verteiler?
* Excel ist nicht für Normalbenutzer, eine App wäre besser
* Metriken, um "heiße Diskussionen" zu erkennen
* Signatur unter jede Mail

# Development

```bash
# Create the database cluster if it does not exist yet.
# See brew info postgresql on how to start the database server.
initdb -D /usr/local/var/postgres-10

# Create the dev database
createdb elternverteiler_dev

# Configure the DB URI
export DB=postgres://localhost/elternverteiler_dev

# Migrate the database
bundle exec rake db:migrate

# Run the web app
rerun -i 'spec/*' bundle exec rackup
```

# Test

```bash
dropdb elternverteiler_test; createdb elternverteiler_test; rake db:migrate
bundle exec rake
```

If desired, restore a backup from within the app in order to get some real data.

# Troubleshooting

## Use the `sequel` database monitor

```bash
$ bundle exec sequel $DB
```

# Deployment

* Backup needs a GCP bucket

  1. Create a [service account](https://console.cloud.google.com/iam-admin/serviceaccounts?project=sgh-elternbeirat&authuser=2) (Account: uhlig-consulting.net, Project: SGH Elternbeirat)

    ![](docs/create-service-account-storage-admin.png)

  1. Download the credentials file. Export its contents as environment variable `STORAGE_KEYFILE_JSON`; the Ruby API will read it.

  1. Create a bucket `sgh-elternbeirat-app-backup`. No extra ACLs are necessary because the service account is already storage admin from the previous step.

* Setup the database

  ```bash
  $ createdb elternverteiler
  $ export DB=postgres://localhost/elternverteiler
  $ bundle exec rake db:migrate
  $ export RACK_ENV=production
  $ puma
  ```
