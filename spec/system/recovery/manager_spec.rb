# frozen_string_literal: true

require 'spec_helper'
require 'sgh/elternverteiler/recovery'
require 'tmpdir'
require 'tempfile'
require 'English'
require 'shellwords'
require 'zlib'

describe Recovery::Manager do
  subject { described_class.new(root, db_url) }
  let(:root) { Pathname(Dir.mktmpdir) }
  let(:db_url) { "postgres://localhost/#{@db_name}" }

  before(:all) do
    @db_dir = Pathname(Dir.mktmpdir('recovery-manager-test-'))
    @db_name = 'elternverteiler-systemtest'

    %x(initdb -D #{Shellwords.escape(@db_dir)})
    expect($CHILD_STATUS.success?).to be_truthy

    %x(createdb #{@db_name})
    expect($CHILD_STATUS.success?).to be_truthy
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

  context 'the items table exists' do
    before do
      @db.create_table :items do
        primary_key :id
        String :name
        Float :price
      end
    end

    after do
      @db.drop_table :items
    end

    around do |example|
      Sequel.connect(db_url) do |db|
        @db = db
        example.run
        @db = nil
      end
    end

    it 'starts out empty' do
      expect(@db[:items].count).to eq(0)
    end

    context 'with some rows' do
      let(:id) { @db[:items].insert(name: 'abc', price: 42) }

      it 'restores a previous state (full roundtrip)' do
        # backup _before_ making a mistake
        subject.backup(Recovery::Backup.new('before price change'))

        # kill that row
        @db[:items].where(id: id).delete
        expect(@db[:items].where(id: id).count).to be_zero

        # oops, we need to restore
        subject.restore(subject.all.first)

        # make sure we are back to normal
        item = @db[:items].where(id: id)
        expect(item).to be
      end
    end

    context 'with an existing backup' do
      let(:backup_file) { root / 'some backup.gz' }

      before do
        # create an artificial backup
        Zlib::GzipWriter.open(backup_file) do |f|
          f.write <<~HEREDOC.chomp
            DROP TABLE items;
            CREATE TABLE items (
                id integer NOT NULL,
                name text,
                price double precision
            );
            INSERT INTO items VALUES (1, 'Bananas', 105);
          HEREDOC
        end
      end

      it 'restores the backup' do
        backups = subject.all
        expect(backups).to_not be_empty
        subject.restore(backups.first)
        expect(@db[:items].count).to eq(1)
      end
    end
  end
end
