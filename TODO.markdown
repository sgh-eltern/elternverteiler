* Export and scp the email list from the UI
* Refactor the duplicate queries in app.rb to methods on the app instance
* Idee von Monika Beck: elternvertreter-9c@schickhardt...
* Use Ruby's [faker gem](https://github.com/stympy/faker) in tests (maybe there is a Simpsons domain?)
* Rename a class (will be useful for moving up after summer)
* Delete a class with all pupils (J2 leaves after Abitur)
  => Make sure parents with other kids in school are kept
* Dropdown boxes have the class list in the wrong order
* Save backups to object storage instead of the local filesystem
  => Encrypt using gpg: `backup-encryption.markdown`
* Double-check web security
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
* Can we build an audit trail, or at least add a note of what happened?
* Some roles are being delegated from the Elternbeirat, and not from the class (e.g. Schulkonferenz). For those, do not record the class where the parent is having this role for, or at least do not show it (in `to_s` etc)
* Full-text search
