# frozen_string_literal: true
require 'spec_helper'

require 'sgh/elternverteiler/postmap_parser'

describe PostmapParser do
  let(:contents) { <<~CONTENT
    # all parents
    eltern@springfield-elementary.edu homer@simpson.org,marge@simpson.org,luann@vanhouten.org,kirk@vanhouten.org,eddie@muntz.org

    # 4th grade
    eltern-4@springfield-elementary.edu homer@simpson.org,marge@simpson.org,luann@vanhouten.org,kirk@vanhouten.org

    # 2nd grade
    eltern-2@springfield-elementary.edu homer@simpson.org,marge@simpson.org
  CONTENT
  }

  subject(:parser) { described_class.new }

  it 'has the expected number of lists' do
    expect(parser.parse(contents).size).to eq(3)
  end

  it 'has the expected lists' do
    expect(parser.parse(contents).keys).to include('eltern@springfield-elementary.edu')
    expect(parser.parse(contents).keys).to include('eltern-4@springfield-elementary.edu')
    expect(parser.parse(contents).keys).to include('eltern-2@springfield-elementary.edu')
  end

  it 'has the expected addresses' do
    expect(parser.parse(contents)['eltern@springfield-elementary.edu']).to include('eddie@muntz.org')
    expect(parser.parse(contents)['eltern-4@springfield-elementary.edu']).to include('luann@vanhouten.org')
    expect(parser.parse(contents)['eltern-2@springfield-elementary.edu']).to include('marge@simpson.org')
  end
end
