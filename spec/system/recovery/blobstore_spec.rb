# frozen_string_literal: true

require 'tempfile'
require 'google/cloud/storage'
require 'open-uri'

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
      let(:blob_name) { 'stuff with space' }
      let(:blob_content) { 'foobar' }
      let(:local_blob_file) { Pathname.new(Dir.mktmpdir) / blob_name }

      before do
        local_blob_file.write(blob_content)
        bucket.create_file(local_blob_file.to_s, blob_name)
      end

      after { bucket.file(blob_name)&.delete }

      it 'can be stored and retrieved' do
        blob = bucket.file(blob_name)
        expect(blob).to be

        content = blob.download.read

        expect(content).to be
        expect(content).to_not be_empty
        expect(content).to eq(blob_content)
      end

      it 'is listed as entry of the bucket' do
        expect(bucket.files.map(&:name)).to include(blob_name)
      end

      it 'is has a name' do
        expect(bucket.file(blob_name).name).to eq(blob_name)
      end

      it 'is has a creation date' do
        expect(bucket.file(blob_name).created_at).to be
      end

      it 'can be downloaded to a local file' do
        Tempfile.create do |file|
          bucket.file(blob_name).download(file.path)
          expect(file.read).to eq('foobar')
        end
      end

      it 'can be fetched anonymously' do
        skip <<~EOS.chomp
          google-cloud-ruby has broken escaping. It creates + for spaces with CGI.escape, where %20 would be correct.
          This was introduced here: https://github.com/GoogleCloudPlatform/google-cloud-ruby/commit/403ac382e943809a0ea93c51b786a123fab98f09#diff-030a250aa9bc3edca850f0e6158da318L44
        EOS

        expect(open(bucket.file(blob_name).signed_url).read).to eq(blob_content)
      end
    end
  end
end
