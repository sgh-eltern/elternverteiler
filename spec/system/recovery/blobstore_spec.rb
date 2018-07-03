require 'tempfile'
require 'google/cloud/storage'

#
# Explore the GCP storage API
#
describe 'Google Cloud Storage' do
  let(:blobstore) {
    Google::Cloud::Storage.new(
      # Credentials are read from ENV['STORAGE_KEYFILE_JSON']
      project_id: 'sgh-elternbeirat'
    )
  }

  context 'an empty bucket' do
    let(:bucket_name) { "test-sgh-elternverteiler-#{Time.now.to_i}" }
    let(:bucket) { blobstore.bucket(bucket_name) }

    before { blobstore.create_bucket(bucket_name) }
    after { bucket.delete }

    it 'exists' do
      expect(bucket).to be
    end

    it 'has no files' do
      expect(bucket.files).to be_empty
    end

    context 'a test file' do
      let(:blob_name) { 'stuff' }
      let(:local_blob_file) { Pathname.new(Dir.mktmpdir) / blob_name }

      before do
        local_blob_file.write('foobar')
        bucket.create_file(local_blob_file.to_s, blob_name)
      end

      after { bucket.file(blob_name)&.delete }

      it 'can be stored and retrieved' do
        blob = bucket.file(blob_name)
        expect(blob).to be

        content = blob.download.read

        expect(content).to be
        expect(content).to_not be_empty
        expect(content).to eq('foobar')
      end

      it 'is listed as entry of the bucket' do
        expect(bucket.files.map{|f| f.name}).to include(blob_name)
      end

      it 'is has a name' do
        expect(bucket.file(blob_name).name).to eq(blob_name)
      end

      fit 'is has a creation date' do
        expect(bucket.file(blob_name).created_at).to be
      end

      it 'can be downloaded to a local file' do
        Tempfile.create do |file|
          bucket.file(blob_name).download(file.path)
          expect(file.read).to eq('foobar')
        end
      end
    end
  end
end
