# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'
ENV['DB'] = 'sqlite:/'

require 'spec_helper'
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
end
