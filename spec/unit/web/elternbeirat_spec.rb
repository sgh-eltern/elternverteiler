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
    expect_any_instance_of(SGH::Elternverteiler::MailServer).to receive(:download).and_return(current_distribution_list)
    post '/verteiler/diff', distribution_list: updated_distribution_list
    expect(last_response).to be_ok
  end

  it 'uploads the new distribution list' do
    expect_any_instance_of(SGH::Elternverteiler::MailServer).to receive(:upload).with(updated_distribution_list, anything)
    post '/verteiler/upload', distribution_list: updated_distribution_list
    expect(last_response.status).to eq(302)
    expect(last_response.location).to eq('/verteiler')
  end
end
