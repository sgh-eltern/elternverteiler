# frozen_string_literal: true

require 'English'
require 'capybara/rspec'
require 'pathname'
require 'securerandom'
require 'sequel'
require 'tmpdir'

module FixtureHelpers
  def create_pupil(last, first, clazz)
    visit '/'
    within('#menu') { click_link('Schüler') }
    click_link('Anlegen')
    fill_in('Vorname', with: first)
    fill_in('Nachname', with: last)
    find('#sgh-elternverteiler-schüler_klasse_id').click
    select(clazz)
    click_button('Anlegen')
  end

  def delete_pupil(last, first, clazz)
    visit '/'
    within('#menu') { click_link('Klassen') }
    within('.content') { click_link(clazz) }
    within('.sgh-elternverteiler-schüler') do
      # TODO This ignores the pupil's first name
      return unless page.has_link?(last)
      click_link(last)
    end

    within('.sgh-elternverteiler-schüler-form') do
      accept_alert { click_button('Löschen') }
    end
  end

  def create_class(stufe, zug=nil)
    visit '/'
    within('#menu') { click_link('Klassen') }
    click_link('Anlegen')
    fill_in('Stufe', with: stufe)
    fill_in('Zug', with: zug)
    click_button('Anlegen')
  end

  def delete_class(name)
    visit '/'
    within('#menu') { click_link('Klassen') }
    within('.content') do
      if page.has_link?(name)
        click_link(name)
        accept_alert { click_button('Löschen') }
      end
    end
  end

  def create_parent(last, first=nil, email=nil)
    visit '/'
    within('#menu') { click_link('Eltern') }
    click_link('Anlegen')
    fill_in('Nachname', with: last)
    fill_in('Vorname', with: first)
    fill_in('Mail', with: email)
    click_button('Anlegen')
  end

  def assign_parent(child, parent)
    visit '/'
    within('#menu') { click_link('Schüler') }
    click_link(child)
    click_link('Hinzufügen')
    find('#sgh-elternverteiler-erziehungsberechtigung_erziehungsberechtigter_id').click
    select(parent)
    click_button('Speichern')
  end

  def delete_parent(last, first=nil, email=nil)
    visit '/'
    within('#menu') { click_link('Eltern') }
    within('.content') do
      if page.has_link?(last)
        click_link(last)
        accept_alert { click_button('Löschen') }
      end
    end
  end

  def create_role(name)
    visit '/'
    within('#menu') { click_link('Rollen') }
    click_link('Anlegen')
    fill_in('Name', with: name)
    click_button('Anlegen')
  end

  def assign_role(klasse, name, role)
    visit '/'
    within('#menu') { click_link('Klassen') }
    within('.content') { click_link(klasse) }
    within('.content') { click_link('Hinzufügen') }

    find('#sgh-elternverteiler-amt_rolle_id').click
    select(role)

    find('#sgh-elternverteiler-amt_inhaber_id').click
    select(name)

    click_button('Speichern')
  end

  def delete_role(name)
    visit '/'
    within('#menu') { click_link('Rollen') }
    within('.content') do
      if page.has_link?(name)
        click_link(name)
        accept_alert { click_button('Löschen') }
      end
    end
  end
end

DB_NAME = "acceptance-test-#{SecureRandom.uuid}"
DB_DIR = Pathname(Dir.mktmpdir('acceptance-test-db_'))

RSpec.configure do |config|
  config.include FixtureHelpers

  Capybara.default_driver = :selenium_chrome

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  # config.disable_monkey_patching!
  config.warnings = false

  # Allows RSpec to persist some state between runs in order to support
  # the `--only-failures` and `--next-failure` CLI options. We recommend
  # you configure your source control system to ignore this file.
  config.example_status_persistence_file_path = 'spec/failure-state'

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed

  config.before(:suite) do
    %x(initdb -D #{Shellwords.escape(DB_DIR)})
    expect($CHILD_STATUS.success?).to be_truthy

    %x(createdb #{DB_NAME})
    expect($CHILD_STATUS.success?).to be_truthy

    Sequel::Model.db = Sequel.connect("postgres://localhost/#{DB_NAME}")
    Sequel.extension :migration
    Sequel::Migrator.run(Sequel::Model.db, 'db/migrations')

    require 'sgh/elternverteiler/web/app'
    Capybara.app = SGH::Elternverteiler::Web::App
  end

  config.before do
    page.switch_to_window(page.current_window) # bring browser window to foreground
  end

  config.after(:suite) do
    Sequel::Model.db.disconnect
    %x(dropdb #{DB_NAME})
    expect($CHILD_STATUS.success?).to be_truthy
    FileUtils.remove_entry(DB_DIR)
  end
end
