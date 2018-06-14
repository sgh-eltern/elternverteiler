# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

task default: ['spec:all']

namespace :spec do
  desc 'Run all tests'
  task all: %w[rubocop:auto_correct unit system acceptance]

  desc 'Run ci tests'
  task ci: ['rubocop:auto_correct', :unit]

  %w[unit system].each do |type|
    desc "Run #{type} tests"
    RSpec::Core::RakeTask.new(type) do |t|
      t.pattern = "spec/#{type}/**/*_spec.rb"
    end
  end

  desc 'Run acceptance tests'
  task :acceptance do
    # Acceptance tests are not fully reentrant yet, so we'd like to run them serially, for now.
    failing_specs = FileList.new('spec/acceptance/*_spec.rb').map do |spec|
      sh "bundle exec rspec #{spec}"
      nil
    rescue StandardError
      spec
    end.compact

    warn "#{failing_specs.size} specs failed: #{failing_specs}" if failing_specs.any?
  end
end

RuboCop::RakeTask.new

namespace :db do
  require 'sequel'

  desc 'Run database migrations'
  task :migrate, [:version] do |_, args|
    Sequel.extension :migration

    if args[:version].nil?
      puts 'Migrating to latest'
      Sequel::Migrator.run(db, File.join(__dir__, 'db/migrations'))
    else
      puts "Migrating to version #{args[:version]}"
      Sequel::Migrator.run(
        db,
        File.join(__dir__, 'db/migrations'),
        target: args[:version].to_i
      )
    end
  end

  def db
    @db ||= Sequel.connect(ENV.fetch('DB'))
  end
end
