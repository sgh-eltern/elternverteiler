# frozen_string_literal: true

require 'spec_helper'
require 'sgh/elternverteiler/klasse_presenter'

describe KlassePresenter do
  subject { described_class.new('4a', 'eltern-4a@springfield-elementary.edu') }

  context 'without any parents' do
    it 'returns an empty string' do
      expect(subject.to_s).to eq('')
    end
  end

  context 'Sherri and Terri' do
    before do
      jerri = Erziehungsberechtigter.new(vorname: 'Jerri', nachname: 'Mackleberry', mail: 'jerri@mackleberry.org').save
      barry = Erziehungsberechtigter.new(nachname: 'Mackleberry', mail: 'barry@mackleberry.org').save
      sherri = Schüler.new(vorname: 'Sherri', nachname: 'Mackleberry', klasse: '4a').save
      sherri.add_eltern(jerri)
      sherri.add_eltern(barry)
      terri = Schüler.new(vorname: 'Terri', nachname: 'Mackleberry', klasse: '4a').save
      terri.add_eltern(jerri)
      terri.add_eltern(barry)
    end

    it 'lists Jerri' do
      expect(subject.to_s).to include('jerri@mackleberry.org')
    end

    it 'lists Barry' do
      expect(subject.to_s).to include('barry@mackleberry.org')
    end

    it 'has no dupes' do
      addresses = subject.to_s.split(' ').last.split(',')
      expect(addresses.size).to eq(addresses.uniq.size)
    end
  end

  context 'with some parents in 4th and some in 5th grade' do
    before do
      bart = Schüler.new(vorname: 'Bart', nachname: 'Simpson', klasse: '4a').save
      homer = Erziehungsberechtigter.new(vorname: 'Homer', nachname: 'Simpson', mail: 'homer@simpson.org').save
      marge = Erziehungsberechtigter.new(vorname: 'Marge', nachname: 'Simpson', mail: 'marge@simpson.org').save
      bart.add_eltern(homer)
      bart.add_eltern(marge)

      milhouse = Schüler.new(vorname: 'Milhouse', nachname: 'Van Houten', klasse: '4a').save
      lyann = Erziehungsberechtigter.new(vorname: 'Luann', nachname: 'Van Houten', mail: 'luann@vanhouten.org').save
      kirk = Erziehungsberechtigter.new(vorname: 'Kirk', nachname: 'Van Houten', mail: 'kirk@vanhouten.org').save
      milhouse.add_eltern(lyann)
      milhouse.add_eltern(kirk)

      kyle = Schüler.new(vorname: 'Kyle', nachname: 'LaBianco', klasse: '5a').save
      kyles_dad = Erziehungsberechtigter.new(nachname: 'LaBianco', mail: 'kyle@labianco.com').save
      kyle.add_eltern(kyles_dad)
    end

    it 'starts with the distribution list address' do
      expect(subject.to_s).to start_with('eltern-4a@springfield-elementary.edu')
    end

    it 'contains the addresses of all parents' do
      expect(subject.to_s).to include('homer@simpson.org')
      expect(subject.to_s).to include('marge@simpson.org')
      expect(subject.to_s).to include('luann@vanhouten.org')
      expect(subject.to_s).to include('kirk@vanhouten.org')
      expect(subject.to_s).to_not include('kyle@labianco.com')
    end

    it 'does not contain empty fields' do
      expect(subject.to_s).to_not end_with(',')
      expect(subject.to_s).to_not include(',,')
    end
  end
end
