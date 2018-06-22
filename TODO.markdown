# Domain

* Export and scp the email list (with the real file name) from the UI
* `Klasse` belongs to `Stufe`; will allow us to get all Klassen 7 with `Stufe.where(name: 7).klassen`
  - This is also the place where `elternvertreter` is implemented so we can get `Stufe.where(name: 7).elternvertreter`. It will allow us to replace `klassenstufe_elternvertreter` in the views.
* `mailing_list` should be a virtual property of some of the models, so that we can say things like `Klasse.where(stufe: '7', zug: 'C').mailing_list`, Stufe.where(name: '8'), klasse9b.elternvertreter.mailing_list
  - This also allows us to enforce uniqueness of the mailing list's name (e.g. eltern-5c)
  - Members come from the instance where the new MailingList is created
* Add ability to rename a class (will be useful for moving up after summer)
* Add ability to delete a class with all pupils (J2 leaves after Abitur)
  => Make sure parents with other kids in school are kept
* Rolle needs a slug besides the current name, which should actually be longer and more descriptive
  => This will become edit for a role, and thus we will get updated_at etc. as well
* Pressing "Add a pupil" (within a class list) selects the right class in the dropdown of the "New Pupil" form
* navbar must not be printed
* navbar should be extracted into partial
* More validations:
  - There can only be one EBV1 / EBV2
  - Only EV can become EBV
  - A person can only be EV in a class of their children
  - EBV1 cannot be elected member of the SK
* Dropdown boxes have the class list in the wrong order
* Save backups to object storage instead of the local filesystem
  => Encrypt using gpg: `backup-encryption.markdown`
* Some roles are being delegated from the Elternbeirat, and not from the class (e.g. Schulkonferenz). For those, do not record the class where the parent is having this role for, or at least do not show it (in `to_s` etc)

# Development / Technical Dept

* If still relevant, implement `views/verteiler/_distribution_list.erb` using the MailingList class, like `views/verteiler/show.erb`
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
