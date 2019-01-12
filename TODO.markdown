# Domain

* Schüler may have an eMail address, too. This may be helpful for those that are members of the Schulkonferenz.
* Amt needs a new field `address` where we can specify the (unique) short address of the mailing list for the Amtsinhaber
* Amt needs a new field `slug` ("ev1") besides the long name (which should actually be longer and more descriptive, like "1. Elternvertreter")
* The following are composite roles, made by combining two or more other roles:
  - elternvertreter
  - elternbeiratsvorsitzende
  - elternvertreter_schulkonferenz
  - delegierte_gesamtelternbeirat

* Change the `PostmapPresenter` to present a `MailingList`
* Find duplicate entries, maybe merge them
* Vor Neuwahl der EBV gibt es keine gewählten Vertreter mehr; löschen ist aber im UI noch nicht drin.

  Manuell: 'Amtsperiode.where( amt: Amt.first(name: '1.EBV')).map(&:delete)'

* Tests for `bin/bump`
  - Also add ability to rename an Amt
* Extract the many `define_singleton_method` calls into a common one, maybe as a method on all Amt#inhaber. With this, concepts like "Elternbeiratsvorsitzende" become a compound of multiple instances of Amt
* Amtsperioden could be ordered, which would allow us to have a generic EV, and the order determines who is EV1 and who's EV2 in a Klasse. Same for EBV etc. This would even allow more than two EV per Klasse.
* Amtsperiode beginnt an einem Datum und endet optional
  - Amt kann auch unbesetzt sein (keine Periode definiert)
  - Amtsperiode hat Historie (wer hat das Amt wann besetzt)
  - Für jede Person kann man abfragen (anzeigen), zu welchem Zeitpunkt sie ein Amt inne hatte (welche Amtsperioden)
* neue Ämter einführen, die bisher nicht im Spreadsheet sind:
  - Kassenführung
  - Kassenprüfung 1 und 2
  - Protokollführung 1 und 2
  - Vertreter im GEB
  - Vertreter 1,2 und 3 in der Schulkonferenz und deren Stellvertreter
* For J1 and J2: `Elternvertreter der J1 == Elternvertreter der Klassenstufe J1`
* Pressing "Add a pupil" (within a class list) selects the right class in the dropdown of the "New Pupil" form
* There can only be one EBV1 / EBV2
* Only EV can become EBV
* A person can only be EV in a class of their children
* EBV1 is member of SK by design and cannot be elected as member of the SK
* Dropdown boxes have the class list in the wrong order
* Some roles are being delegated from the Elternbeirat, and not from the class (e.g. Schulkonferenz). For those, do not record the class where the parent is having this role for, or at least do not show it (in `to_s` etc)
* New views under Verteiler
  - '/verteiler/klassen': '&nbsp;Eltern',
  - '/verteiler/klassenstufen': '&nbsp;Klassenstufen',
  - '/verteiler/eltern': '&nbsp;Alle Eltern',
  - '/verteiler/elternbeirat': '&nbsp;Elternbeirat',

# Development / Technical Dept

* Refactor the duplicate queries in app.rb to methods on the app instance
* `plugin :csrf`
* rubocop-rspec
* https://github.com/ericqweinstein/ruumba
* Double-check web security
* Use Ruby's [faker gem](https://github.com/stympy/faker) in tests (maybe there is a Simpsons domain?)

# Authorization

* Do not show anything without login
* Show the list of all EV (without details) to unauthenticated users (read-only, not even buttons)
* Show the list of all EBR (without details) to unauthenticated users (read-only, not even buttons)
* Show the list of all SK (without details) to unauthenticated users (read-only, not even buttons)
* Show _how many_ parents are unreachable by eMail to an EV of this class
  => Needs login via magic link, e.g. with [Caddy's multipass](https://github.com/namsral/multipass) in front of the app
* EV can see the the details of every EBR member
  => Needs login via magic link
* Parents (incl. EV) can see the classes of their children (read-only, not even buttons)
  => Needs login via magic link

# Misc

* Can we build an audit trail, or at least add a note of what happened?
* Full-text search
