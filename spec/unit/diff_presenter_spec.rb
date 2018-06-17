# frozen_string_literal: true

require 'hashdiff'
require 'sgh/elternverteiler/postmap_parser'

describe 'diff presentation' do
  let(:parser){ SGH::Elternverteiler::PostmapParser.new }

  let(:current) { parser.parse <<~CONTENT
    # all parents
    eltern@springfield-elementary.edu homer@simpson.org,marge@simpson.org,kirk@vanhouten.org,eddie@muntz.org

    # 4th grade
    eltern-4@springfield-elementary.edu homer@simpson.org,marge@simpson.org,kirk@vanhouten.org

    # 2nd grade
    eltern-2@springfield-elementary.edu homer@simpson.org,marge@simpson.org
  CONTENT
  }

  let(:updated) { parser.parse <<~CONTENT
    # all parents
    eltern@springfield-elementary.edu homer@simpson.org,marjoriee@simpson.org,luann@vanhouten.org,kirk@vanhouten.org

    # 4th grade
    eltern-4@springfield-elementary.edu homer@simpson.org,marjoriee@simpson.org,luann@vanhouten.org,kirk@vanhouten.org

    # 2nd grade
    eltern-2@springfield-elementary.edu homer@simpson.org,marjoriee@simpson.org
  CONTENT
  }

  context 'Marge changes her eMail address' do
    it "shows Marge's old address as removed from eltern-2" do
      diff = HashDiff.diff(current, updated)
      i = 0
      expect(diff[i][0]).to eq('-')
      expect(diff[i][1]).to eq('eltern-2@springfield-elementary.edu[1]')
      expect(diff[i][2]).to eq('marge@simpson.org')
    end

    it "shows Marge's new address as added to eltern-2" do
      diff = HashDiff.diff(current, updated)
      i = 1
      expect(diff[i][0]).to eq('+')
      expect(diff[i][1]).to eq('eltern-2@springfield-elementary.edu[1]')
      expect(diff[i][2]).to eq('marjoriee@simpson.org')
    end

    it "shows Marge's old address as removed from eltern-4" do
      diff = HashDiff.diff(current, updated)
      i = 2
      expect(diff[i][0]).to eq('-')
      expect(diff[i][1]).to eq('eltern-4@springfield-elementary.edu[2]')
      expect(diff[i][2]).to eq('marge@simpson.org')
    end

    it "shows Marge's new address as added to eltern-4" do
      diff = HashDiff.diff(current, updated)
      i = 4
      expect(diff[i][0]).to eq('+')
      expect(diff[i][1]).to eq('eltern-4@springfield-elementary.edu[3]')
      expect(diff[i][2]).to eq('marjoriee@simpson.org')
    end

    it "shows Marge's old address as removed from eltern" do
      diff = HashDiff.diff(current, updated)
      i = 6
      expect(diff[i][0]).to eq('-')
      expect(diff[i][1]).to eq('eltern@springfield-elementary.edu[2]')
      expect(diff[i][2]).to eq('marge@simpson.org')
    end

    it "shows Marge's new address as added to eltern" do
      diff = HashDiff.diff(current, updated)
      i = 8
      expect(diff[i][0]).to eq('+')
      expect(diff[i][1]).to eq('eltern@springfield-elementary.edu[3]')
      expect(diff[i][2]).to eq('marjoriee@simpson.org')
    end
  end

  context 'Luann VanHouten is added' do
    it "shows Luann's eMail address as added to eltern-4" do
      diff = HashDiff.diff(current, updated)
      i = 3
      expect(diff[i][0]).to eq('+')
      expect(diff[i][1]).to eq('eltern-4@springfield-elementary.edu[2]')
      expect(diff[i][2]).to eq('luann@vanhouten.org')
    end

    it "shows Luann's eMail address as added to eltern" do
      i = 7
      diff = HashDiff.diff(current, updated)
      expect(diff[i][0]).to eq('+')
      expect(diff[i][1]).to eq('eltern@springfield-elementary.edu[2]')
      expect(diff[i][2]).to eq('luann@vanhouten.org')
    end
  end

  context 'Eddie Muntz was removed' do
    it 'shows eddie@muntz.org as removed from eltern' do
      diff = HashDiff.diff(current, updated)
      i = 5
      expect(diff[i][0]).to eq('-')
      expect(diff[i][1]).to eq('eltern@springfield-elementary.edu[0]')
      expect(diff[i][2]).to eq('eddie@muntz.org')
    end
  end
end
