# frozen_string_literal: true

require 'spec_helper'

describe Klasse do
  subject(:klasse_4a) { described_class.new(stufe: '4', zug: 'a').save }

  it 'has a string representation' do
    expect(klasse_4a.to_s).to eq('4a')
  end

  context 'some kids with parents' do
    let(:sherri) { Schüler.new(vorname: 'Sherri', nachname: 'Mackleberry', klasse: klasse_4a).save }
    let(:terri) { Schüler.new(vorname: 'Terri', nachname: 'Mackleberry', klasse: klasse_4a).save }
    let(:jerri) { Erziehungsberechtigter.new(vorname: 'Jerri', nachname: 'Mackleberry', mail: 'jerri@mackleberry.org').save }
    let(:barry) { Erziehungsberechtigter.new(nachname: 'Mackleberry', mail: 'barry@mackleberry.org').save }

    before do
      sherri.add_eltern(jerri)
      sherri.add_eltern(barry)
      terri.add_eltern(jerri)
      terri.add_eltern(barry)
    end

    it 'has the expected pupils' do
      expect(klasse_4a.schüler).to include(sherri)
      expect(klasse_4a.schüler).to include(terri)
    end

    it 'has the expected parents' do
      expect(klasse_4a.eltern).to include(jerri)
      expect(klasse_4a.eltern).to include(barry)
    end

    context 'some 5th graders with their parents' do
      let(:k5a) { described_class.new(stufe: '5', zug: 'a').save }
      let(:kyle) { Schüler.new(vorname: 'Kyle', nachname: 'LaBianco', klasse: k5a).save }
      let(:kyles_dad) { Erziehungsberechtigter.new(nachname: 'LaBianco', mail: 'kyle@labianco.com').save }

      before do
        kyle.add_eltern(kyles_dad)
      end

      it 'does not include parents from other grades' do
        expect(klasse_4a.eltern).to include(barry)
        expect(klasse_4a.eltern).to_not include(kyles_dad)
      end
    end

    context 'some kids without parents' do
      let(:prius) { Schüler.new(vorname: 'Prius', nachname: 'Albertson', klasse: klasse_4a).save }

      it 'has the expected amount of parents' do
        expect(klasse_4a.eltern.size).to eq(2)
      end
    end
  end
end
