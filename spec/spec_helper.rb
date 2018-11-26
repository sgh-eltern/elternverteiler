# frozen_string_literal: true

require 'sequel'

Sequel::Model.db = Sequel.sqlite
Sequel.extension :migration
Sequel::Migrator.run(Sequel::Model.db, 'db/migrations')

require 'sgh/elternverteiler'
# rubocop:disable Style/MixinUsage
include SGH::Elternverteiler
# rubocop:enable Style/MixinUsage

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
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

  config.around(:each) do |example|
    Sequel::Model.db.transaction(rollback: :always, auto_savepoint: true) { example.run }
  end
end
