# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'
ENV['DB'] = 'sqlite:/'

require 'rack/test'
require 'sgh/elternverteiler/web/app'

describe SGH::Elternverteiler::Web::App do
  include Rack::Test::Methods

  def app
    described_class
  end

  it 'has a root page' do
    get '/'
    expect(last_response).to be_ok
  end

  it 'shows the current distribution list' do
    get '/verteiler'
    expect(last_response).to be_ok
    expect(last_response.body).to include('Klassen')
  end

  it "downloads the server's distribution list" do
    expect_any_instance_of(SGH::Elternverteiler::MailServer).to receive(:download)
    get '/verteiler/diff'
    expect(last_response).to be_ok
  end

  it 'uploads the new distribution list' do
    put '/verteiler/diff'
    expect(last_response).to be_ok
  end
end
