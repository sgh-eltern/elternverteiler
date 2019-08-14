# frozen_string_literal: true

require 'spec_helper'

require 'sgh/elternverteiler/lehrer-diff/fetcher'

describe LehrerDiff::Fetcher do
  subject(:lehrer) { described_class.new(fixture('lehrer.html')).fetch }

  it 'yields a non-empty set of Lehrer' do
    expect(lehrer).to_not be_empty
  end

  it 'fetches the expected amount of Lehrer' do
    expect(lehrer.size).to eq(76)
  end

  %I[kürzel nachname vorname fächer].each do |attr|
    it "yields Lehrer that all have a non-empty '#{attr}' attribute" do
      lehrer.each do |l|
        expect(l[attr]).to_not be_empty, "expected #{attr} of #{l} to not be empty, but it was"
      end
    end
  end

  context 'Lehrer with Umlauts' do
    subject(:with_umlaut) do
      lehrer.select do |l|
        l[:nachname].include?('ä') \
     || l[:nachname].include?('ö') \
     || l[:nachname].include?('ü') \
     || l[:nachname].include?('ß')
      end
    end

    it 'has the expected number of Lehrer with umlaut' do
      expect(with_umlaut.size).to eq(10), "expected #{with_umlaut} to be 10"
    end
  end
end
