# frozen_string_literal: true

require 'sgh/elternverteiler/recovery'
require 'zlib'
require 'google/cloud/storage'
require_relative '../helpers/postgres'

describe Recovery::BlobstoreManager do
  def example_id
    @example_id ||= "blobstore_manager-systemtest-#{Time.now.to_i}"
  end

  subject(:backup_manager) { described_class.new(bucket, db_url) }

  let(:bucket) { blobstore.bucket(example_id) }
  let(:blobstore) { Google::Cloud::Storage.new(project_id: 'sgh-elternbeirat') }
  let(:db_url) { "postgres://localhost/#{example_id}" }

  before(:all) do
    PostgresHelpers.create_db(example_id)
  end

  before do
    blobstore.create_bucket(example_id)
  end

  after do
    blobstore&.bucket(example_id)&.delete
  end

  after(:all) do
    PostgresHelpers.drop_db(example_id)
  end

  context 'empty database URL' do
    let(:db_url) { '' }

    it 'raises an error' do
      expect { backup_manager }.to raise_error(StandardError) do |err|
        expect(err.message).to match(/empty/)
      end
    end
  end

  context 'non-existing bucket' do
    let(:bucket) { double }

    before do
      allow(bucket).to receive(:exists?).and_return(false)
      allow(bucket).to receive(:delete)
    end

    it 'raises an error' do
      expect { backup_manager }.to raise_error(StandardError) do |err|
        expect(err.message).to match(/exist/)
      end
    end
  end

  context 'no bucket' do
    let(:bucket) { nil }

    it 'raises an error' do
      expect { backup_manager }.to raise_error(StandardError) do |err|
        expect(err.message).to match(/nil/)
      end
    end
  end

  context 'empty bucket' do
    let(:backup) { instance_double(Recovery::Backup) }

    before do
      allow(backup).to receive(:name).and_return('my backup')
      allow(backup).to receive(:file_name).and_return('my backup.gz')
    end

    after { bucket.file(backup.file_name)&.delete }

    it 'has an empty list of backups' do
      expect(backup_manager.all).to be_empty
    end

    it 'creates a new backup' do
      backup_manager.backup(backup)
      expect(bucket.files).to_not be_empty
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

    around do |example|
      Sequel.connect(db_url) do |db|
        @db = db
        example.run
        @db = nil
      end
    end

    after do
      @db.drop_table :items
      bucket.files.each(&:delete)
    end

    it 'starts out empty' do
      expect(@db[:items].count).to eq(0)
    end

    context 'with some rows' do
      let(:id) { @db[:items].insert(name: 'abc', price: 42) }

      it 'restores a previous state (full roundtrip)' do
        # backup _before_ making a mistake
        backup_manager.backup(Recovery::Backup.new(name: 'before price change'))

        # kill that row
        @db[:items].where(id: id).delete
        expect(@db[:items].where(id: id).count).to be_zero

        # oops, we need to restore
        backup_manager.restore(backup_manager.all.first)

        # make sure we are back to normal
        item = @db[:items].where(id: id)
        expect(item).to be
      end
    end

    context 'with an existing backup' do
      before do
        Zlib::GzipWriter.open(@backup_file) do |f|
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

        bucket.create_file(@backup_file.path)
      end

      around do |example|
        Tempfile.create('backup_file.gz') do |tmp_file|
          @backup_file = tmp_file
          example.run
          @backup_file = nil
        end
      end

      it 'restores the backup' do
        backups = backup_manager.all
        expect(backups).to_not be_empty
        backup_manager.restore(backups.first)
        expect(@db[:items].count).to eq(1)
      end
    end
  end
end
