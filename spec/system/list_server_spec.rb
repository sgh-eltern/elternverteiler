# frozen_string_literal: true

require 'sgh/elternverteiler/list_server'
require 'securerandom'

# rubocop:disable Style/MixinUsage
include SGH::Elternverteiler
# rubocop:enable Style/MixinUsage

describe ListServer do
  subject(:server) { described_class.new(server: nil, user: nil, private_key: nil) }
  let(:random_string) { SecureRandom.uuid }

  before do
    allow(Net::SSH).to receive(:start).and_return(random_string)
  end

  it 'provides the server copy of the distribution list' do
    expect(server.download).to_not be_empty
  end

  it 'can up- and download a custom file' do
    server.upload(random_string, 'system-test')
    expect(server.download('system-test')).to eq(random_string)
  end
end
