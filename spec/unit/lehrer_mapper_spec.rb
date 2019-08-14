# frozen_string_literal: true

require 'spec_helper'

require 'sgh/elternverteiler/lehrer_mapper'

describe LehrerMapper do
  subject(:lehrer) { described_class.new.map(fixture('lehrer.html').read).each }

  it 'has Lehrer' do
    expect(lehrer.to_a).to_not be_empty
  end

  it 'has the expected amount of Lehrer' do
    expect(lehrer.size).to eq(76)
  end

  %I[kürzel nachname vorname fächer email].each do |attr|
    it "has Lehrer that all have an #{attr} attribute" do
      expect(lehrer).to all(respond_to(attr))
    end

    it "has Lehrer that all have a non-empty #{attr}" do
      lehrer.each do |l|
        expect(l.send(attr)).to_not be_empty, "expected #{attr} of #{l} to not be empty, but it was"
      end
    end
  end

  it 'has Lehrer with a title of Dr.' do
    with_title = lehrer.reject { |l| l.titel.nil? }
    expect(with_title).not_to be_empty
    expect(with_title.size).to eq(3)
    expect(with_title.map(&:titel)).to all(eq('Dr.'))
  end

  context 'duplicate surnames' do
    subject(:duplicate_surnames) do
      lehrer.group_by(&:nachname).select { |_, group| group.size > 1 }
    end

    it 'resolves Scherer as unique email addresses' do
      scherers = duplicate_surnames['Scherer']
      expect(scherers.map(&:email)).to include('t.scherer@sgh-mail.de')
      expect(scherers.map(&:email)).to include('k.scherer@sgh-mail.de')
    end

    it 'resolves Schmid as unique email addresses' do
      schmids = duplicate_surnames['Schmid']
      expect(schmids.map(&:email)).to include('r.schmid@sgh-mail.de')
      expect(schmids.map(&:email)).to include('k.schmid@sgh-mail.de')
    end
  end

  context 'Lehrer with Umlauts' do
    subject(:with_umlaut) do
      lehrer.select do |l|
        l.nachname.include?('ä') \
     || l.nachname.include?('ö') \
     || l.nachname.include?('ü') \
     || l.nachname.include?('ß')
      end
    end

    it 'has the expected number of Lehrer with umlaut' do
      expect(with_umlaut.size).to eq(10)
    end

    it 'translates umlauts in email addresses' do
      umlaut_mails = with_umlaut.map(&:email)

      expected_addresses = %w[
        argueellez-fernandez@sgh-mail.de bertsch-noedinger@sgh-mail.de
        geissler@sgh-mail.de haeberle@sgh-mail.de
        haerter@sgh-mail.de hoefelein@sgh-mail.de
        jaensch@sgh-mail.de loehlein@sgh-mail.de
        mueller@sgh-mail.de oeztuerk@sgh-mail.de
      ]

      expected_addresses.each do |expected_address|
        expect(umlaut_mails).to include(expected_address)
      end

      umlaut_mails.each do |umlaut_mail|
        expect(expected_addresses).to include(umlaut_mail)
      end
    end
  end

  context 'Dr. Wiebel' do
    subject(:dr_wiebel) { lehrer.select { |l| l.nachname == 'Wiebel' && l.vorname == 'Dirk' }.first }

    it 'removes titles from email addresses' do
      expect(dr_wiebel.email).to eq('wiebel@sgh-mail.de')
    end

    it 'has the last name separate from the title' do
      expect(dr_wiebel.nachname).to eq('Wiebel')
      expect(dr_wiebel.titel).to eq('Dr.')
    end
  end
end
