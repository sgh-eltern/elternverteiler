# frozen_string_literal: true

require 'spec_helper'

describe Klasse do
  subject(:klasse_4a) { described_class.new(stufe: '4', zug: 'a').save }
  let(:jerri) { Erziehungsberechtigter.new(vorname: 'Jerri', nachname: 'Mackleberry', mail: 'jerri@mackleberry.org').save }

  it 'has a string representation' do
    expect(klasse_4a.to_s).to eq('4a')
  end

  context 'some kids with parents' do
    let(:sherri) { Schüler.new(vorname: 'Sherri', nachname: 'Mackleberry', klasse: klasse_4a).save }
    let(:terri) { Schüler.new(vorname: 'Terri', nachname: 'Mackleberry', klasse: klasse_4a).save }
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

  context 'Klasse 4A sends Homer to the PAB' do
    let(:homer) { Erziehungsberechtigter.new(vorname: 'Homer', nachname: 'Simpson').save }
    let(:pab) { Rolle.new(name: 'Member of the Parent Advisory Board').save }

    before do
      Amt.new(
        inhaber: homer,
        rolle: pab,
        klasse: klasse_4a
      ).save
    end

    it 'lists parents with roles' do
      expect(klasse_4a.rollen.size).to eq(1)
    end

    it 'lists the PAB as one of the roles' do
      expect(klasse_4a.rollen).to include(pab)
    end

    context 'Jerri is a cash auditor for 4A' do
      let(:cash_auditor) { Rolle.new(name: 'Cash Auditor').save }

      before do
        Amt.new(
          inhaber: jerri,
          rolle: cash_auditor,
          klasse: klasse_4a
        ).save
      end

      it 'lists Jerri as cash auditor' do
        expect(klasse_4a.inhaber(cash_auditor)).to include(jerri)
      end

      it 'lists Jerri and Homer as PAB member or cash auditor' do
        expect(klasse_4a.inhaber(cash_auditor, pab)).to include(homer)
        expect(klasse_4a.inhaber(cash_auditor, pab)).to include(jerri)
      end
    end

    context 'Klasse 2A sends Marge to the PAB' do
      subject(:klasse_2a) { described_class.new(stufe: '2', zug: 'a').save }
      let(:marge) { Erziehungsberechtigter.new(vorname: 'Marge', nachname: 'Simpson').save }

      before do
        Amt.new(
          inhaber: marge,
          rolle: pab,
          klasse: klasse_2a
        ).save
      end

      it 'lists one holder of a role in this class' do
        expect(klasse_2a.rollen.size).to eq(1)
      end

      it 'has both Marge and Homer as members of the PAB' do
        expect(pab.mitglieder.size).to eq(2)
        expect(pab.mitglieder).to include(marge)
        expect(pab.mitglieder).to include(homer)
      end

      it 'lists Marge as PAB member' do
        expect(klasse_2a.inhaber(pab)).to include(marge)
      end
    end
  end
end
