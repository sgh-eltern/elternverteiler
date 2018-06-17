# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'rubocop/rake_task'
RuboCop::RakeTask.new

task default: ['spec:all']

namespace :spec do
  desc 'Run all tests'
  task all: %w[rubocop:auto_correct unit system acceptance]

  desc 'Run ci tests'
  task ci: ['rubocop', :unit]

  %w[unit system acceptance].each do |type|
    desc "Run #{type} tests"
    RSpec::Core::RakeTask.new(type) do |t|
      t.pattern = "spec/#{type}/**/*_spec.rb"
    end
  end
end

namespace 'parallel:rspec' do
  %i[unit system acceptance].each do |type|
    desc "Run #{type} tests"
    task type do
      abort unless system("parallel_rspec spec/#{type}")
    end
  end
end

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
