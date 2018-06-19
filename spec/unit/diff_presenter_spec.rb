# frozen_string_literal: true

require 'hashdiff'
require 'sgh/elternverteiler/postmap_parser'

describe HashDiff do
  let(:parser) { SGH::Elternverteiler::PostmapParser.new }

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

  let(:diff) { HashDiff.diff(current, updated) }

  context 'Marge changes her eMail address' do
    it "shows Marge's old address as removed from eltern-2" do
      expect(diff[0][0]).to eq('-')
      expect(diff[0][1]).to eq('eltern-2@springfield-elementary.edu[1]')
      expect(diff[0][2]).to eq('marge@simpson.org')
    end

    it "shows Marge's new address as added to eltern-2" do
      expect(diff[1][0]).to eq('+')
      expect(diff[1][1]).to eq('eltern-2@springfield-elementary.edu[1]')
      expect(diff[1][2]).to eq('marjoriee@simpson.org')
    end

    it "shows Marge's old address as removed from eltern-4" do
      expect(diff[2][0]).to eq('-')
      expect(diff[2][1]).to eq('eltern-4@springfield-elementary.edu[2]')
      expect(diff[2][2]).to eq('marge@simpson.org')
    end

    it "shows Marge's new address as added to eltern-4" do
      expect(diff[4][0]).to eq('+')
      expect(diff[4][1]).to eq('eltern-4@springfield-elementary.edu[3]')
      expect(diff[4][2]).to eq('marjoriee@simpson.org')
    end

    it "shows Marge's old address as removed from eltern" do
      expect(diff[6][0]).to eq('-')
      expect(diff[6][1]).to eq('eltern@springfield-elementary.edu[2]')
      expect(diff[6][2]).to eq('marge@simpson.org')
    end

    it "shows Marge's new address as added to eltern" do
      expect(diff[8][0]).to eq('+')
      expect(diff[8][1]).to eq('eltern@springfield-elementary.edu[3]')
      expect(diff[8][2]).to eq('marjoriee@simpson.org')
    end
  end

  context 'Luann VanHouten is added' do
    it "shows Luann's eMail address as added to eltern-4" do
      expect(diff[3][0]).to eq('+')
      expect(diff[3][1]).to eq('eltern-4@springfield-elementary.edu[2]')
      expect(diff[3][2]).to eq('luann@vanhouten.org')
    end

    it "shows Luann's eMail address as added to eltern" do
      expect(diff[7][0]).to eq('+')
      expect(diff[7][1]).to eq('eltern@springfield-elementary.edu[2]')
      expect(diff[7][2]).to eq('luann@vanhouten.org')
    end
  end

  context 'Eddie Muntz was removed' do
    it 'shows eddie@muntz.org as removed from eltern' do
      expect(diff[5][0]).to eq('-')
      expect(diff[5][1]).to eq('eltern@springfield-elementary.edu[0]')
      expect(diff[5][2]).to eq('eddie@muntz.org')
    end
  end
end
