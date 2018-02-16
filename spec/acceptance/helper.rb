# frozen_string_literal: true

require 'English'
require 'capybara/rspec'
require 'pathname'
require 'securerandom'
require 'sequel'
require 'tmpdir'

RSpec.configure do |config|
  Capybara.default_driver = :selenium_chrome # TODO: _headless

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

  config.before(:all) do
    @db_dir = Pathname(Dir.mktmpdir('acceptance-test-db_'))
    @db_name = "acceptance-test-#{SecureRandom.uuid}"

    %x(initdb -D #{Shellwords.escape(@db_dir)})
    expect($CHILD_STATUS.success?).to be_truthy

    %x(createdb #{@db_name})
    expect($CHILD_STATUS.success?).to be_truthy

    Sequel::Model.db = Sequel.connect("postgres://localhost/#{@db_name}")
    Sequel.extension :migration
    Sequel::Migrator.run(Sequel::Model.db, 'db/migrations')

    require 'sgh/elternverteiler/web/app'
    Capybara.app = SGH::Elternverteiler::Web::App
  end

  config.after(:all) do
    Sequel::Model.db.disconnect
    %x(dropdb #{@db_name})
    expect($CHILD_STATUS.success?).to be_truthy
    FileUtils.remove_entry(@db_dir)
  end
end
