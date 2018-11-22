# Elternverteiler

# Development

* Create the database cluster if it does not exist yet.

  See `brew info postgresql` on how to start the database server.

  ```sh
  $ initdb -D /usr/local/var/postgres-10
  ```

* Create the dev database

  ```sh
  $ createdb elternverteiler_dev
  ```

* Configure the DB URI

  ```sh
  $ export DB=postgres://localhost/elternverteiler_dev
  ```

* Migrate the database

  ```sh
  $ bundle exec rake db:migrate
  ```

* Run the web app

  ```sh
  $ rerun -i 'spec/*' bundle exec rackup
  ```

* Run Jobs Manually

  We use `--worker-count 2` so that we do not overload the eMail servers. mailtrap.io at least does not accept more than 2/sec.

  ```sh
  $ que --log-level debug --queue mailer --worker-count 2 ./config/que.rb
  ```

# Test

```sh
$ dropdb elternverteiler_test; createdb elternverteiler_test; rake db:migrate
bundle exec rake
```

If desired, restore a backup from within the app in order to get some real data.

# Troubleshooting

## Use the `sequel` database monitor

```sh
$ bundle exec sequel $DB
```

# Deployment

* Backup needs a GCP bucket

  1. Create a [service account](https://console.cloud.google.com/iam-admin/serviceaccounts?project=sgh-elternbeirat&authuser=2) (Account: uhlig-consulting.net, Project: SGH Elternbeirat)

    ![](docs/create-service-account-storage-admin.png)

  1. Download the credentials file. Export its contents as environment variable `STORAGE_KEYFILE_JSON`; the Ruby API will read it.

  1. Create a bucket `sgh-elternbeirat-app-backup`. No extra ACLs are necessary because the service account is already storage admin from the previous step.

* Setup the database

  ```sh
  $ createdb elternverteiler
  $ export DB=postgres://localhost/elternverteiler
  $ bundle exec rake db:migrate
  ```

* Create and authorize the SCP account

  The app uses SCP to up- and download the distribution list. Create an account that is capable of scp'ing to the server using a private key (the app does not do password authentiation). Configure the app using the following environment variables:

  ```sh
  export list_server_hostname=foo.example.com
  export list_server_username=bar
  export list_server_key_file=~/.ssh/id_rsa
  ```

* Start the app and the background processor

  ```sh
  $ export RACK_ENV=production
  $ gem install foreman
  $ foreman start
  ```

* Show Puma stats

  ```sh
  $ pumactl --control-url unix://var/puma-ctl.sock --control-token ***REMOVED*** stats
  ```
