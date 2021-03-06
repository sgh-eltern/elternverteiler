# frozen_string_literal: true

require 'spec_helper'

ENV['RACK_ENV'] = 'test'
ENV['DB'] = 'sqlite:/'

require 'rack/test'
require 'sgh/elternverteiler/web/app'
require 'sgh/elternverteiler/web/view_helpers'

describe SGH::Elternverteiler::Web::App do
  include Rack::Test::Methods

  def app
    described_class
  end

  def extract_error(last_response)
    doc = Nokogiri::HTML(last_response.body)
    message = doc.css('code.message').text
    backtrace = doc.css('code.backtrace').text
    "Error #{last_response.status}: #{message}\n#{backtrace.lines[0..3].join}..."
  end

  let(:current_distribution_list) { <<~CONTENT
    # all parents
    eltern@springfield-elementary.edu homer@simpson.org,marge@simpson.org,kirk@vanhouten.org,eddie@muntz.org

    # 4th grade
    eltern-4@springfield-elementary.edu homer@simpson.org,marge@simpson.org,kirk@vanhouten.org

    # 2nd grade
    eltern-2@springfield-elementary.edu homer@simpson.org,marge@simpson.org
  CONTENT
  }

  let(:updated_distribution_list) { <<~CONTENT
    # all parents
    eltern@springfield-elementary.edu homer@simpson.org,marjoriee@simpson.org,luann@vanhouten.org,kirk@vanhouten.org

    # 4th grade
    eltern-4@springfield-elementary.edu homer@simpson.org,marjoriee@simpson.org,luann@vanhouten.org,kirk@vanhouten.org

    # 2nd grade
    eltern-2@springfield-elementary.edu homer@simpson.org,marjoriee@simpson.org
  CONTENT
  }

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
    expect_any_instance_of(SGH::Elternverteiler::ListServer).to receive(:download).and_return(current_distribution_list)
    post '/verteiler/diff', distribution_list: updated_distribution_list
    expect(last_response).to be_ok
  end

  it 'uploads the new distribution list' do
    expect_any_instance_of(SGH::Elternverteiler::ListServer).to receive(:upload).with(updated_distribution_list, anything)
    post '/verteiler/upload', distribution_list: updated_distribution_list
    expect(last_response.status).to eq(302)
    expect(last_response.location).to eq('/verteiler')
  end

  context 'non-existing Klasse' do
    it 'returns 404' do
      get '/klassen/5x'
      expect(last_response).to_not be_ok
      expect(last_response.status).to eq(404)
    end
  end

  context 'Klassenstufe 5 exists' do
    include SGH::Elternverteiler::Web::PathHelpers
    let(:klassenstufe_5) { Klassenstufe.create(name: '5') }

    it "shows the Klassenstufe's page when addressed via its name" do
      get klassenstufe_path(klassenstufe_5)
      expect(last_response).to be_ok, extract_error(last_response)
      expect(last_response.body).to include('Klassenstufe 5')
    end

    context 'Klasse 5a exists' do
      let(:k5a) { Klasse.create(stufe: klassenstufe_5, zug: 'A') }

      it "shows the Klasse's page when addressed via its pretty URL" do
        get klasse_path(k5a)
        expect(last_response).to be_ok
        expect(last_response.body).to include('Klasse 5A')
      end
    end
  end
end
