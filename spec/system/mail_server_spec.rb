# frozen_string_literal: true

require 'sgh/elternverteiler/mail_server'
require 'securerandom'

describe MailServer do
  subject(:server) { described_class.new }
  let(:random_string) { SecureRandom.uuid }

  it 'provides the server copy of the distribution list' do
    expect(server.download).to_not be_empty
  end

  it 'can up- and download a custom file' do
    server.upload(random_string, 'system-test')
    expect(server.download('system-test')).to eq(random_string)
  end
end
