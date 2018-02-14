# frozen_string_literal: true

require 'spec_helper'
require 'sgh/elternverteiler/recovery'
require 'tmpdir'
require 'tempfile'
require 'English'
require 'shellwords'
require 'zlib'

describe Recovery::Manager do
  subject { described_class.new(root) }
  let(:root) { Pathname(Dir.mktmpdir) }

  before(:all) do
    @db_dir = Pathname(Dir.mktmpdir)

    %x(initdb -D #{Shellwords.escape(@db_dir)})
    expect($CHILD_STATUS.success?).to be_truthy

    %x(createdb #{@db_name})
    expect($CHILD_STATUS.success?).to be_truthy

    ENV['DB'] = 'postgres://localhost/elternverteiler-systemtest'
    Sequel.extension :migration

    Sequel.connect(ENV.fetch('DB')) do |db|
      Sequel::Migrator.run(db, 'db/migrations')
    end

    # TODO: Load some fixtures or create some users to be backed up and restored
  end

  after do
    FileUtils.remove_entry(root) if root&.exist?
  end

  after(:all) do
    %x(dropdb #{@db_name})
    expect($CHILD_STATUS.success?).to be_truthy
    FileUtils.remove_entry(@db_dir)
  end

  context 'non-existing root directory' do
    let(:root) { Pathname('/does/not/exist') }

    it 'cannot exist' do
      expect { subject }.to raise_error(StandardError) do |err|
        expect(err.message).to match(/does not exist/)
      end
    end
  end

  context 'no root directory' do
    let(:root) { nil }

    it 'cannot exist' do
      expect { subject }.to raise_error(StandardError) do |err|
        expect(err.message).to match(/required/)
      end
    end
  end

  context 'empty root directory' do
    let(:backup) { instance_double(Recovery::Backup) }

    before do
      allow(backup).to receive(:name).and_return('my backup')
    end

    it 'has an empty list of backups' do
      expect(subject.all).to be_empty
    end

    it 'creates a new backup' do
      subject.backup(backup)
      expect(root.children).to_not be_empty
    end
  end
end
