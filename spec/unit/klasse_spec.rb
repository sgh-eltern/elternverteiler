# frozen_string_literal: true

describe Klasse do
  subject(:klasse_4a) { described_class.new(stufe: '4', zug: 'a').save }
  let(:jerri) { Erziehungsberechtigter.new(vorname: 'Jerri', nachname: 'Mackleberry', mail: 'jerri@mackleberry.org').save }

  it 'has a string representation' do
    expect(klasse_4a.to_s).to eq('4a')
  end

  it 'has a name' do
    expect(klasse_4a.name).to eq('4a')
  end

  it 'has a forme namespace' do
    expect(klasse_4a.forme_namespace).to eq('sgh-elternverteiler-klasse')
  end

  it 'cannot create another role with the same stufe and zug' do
    expect do
      described_class.new(stufe: subject.stufe, zug: subject.zug).save
    end.to raise_error(Sequel::UniqueConstraintViolation)
  end

  it 'can create another role with the same stufe, but another zug' do
    expect do
      described_class.new(stufe: subject.stufe, zug: subject.zug.next).save
    end.not_to raise_error
  end

  it 'can create another role with another stufe, but the same zug' do
    expect do
      described_class.new(stufe: subject.stufe.next, zug: subject.zug).save
    end.not_to raise_error
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

    it 'has a mailing list for parents' do
      expect(klasse_4a.mailing_list).to be
      expect(klasse_4a.mailing_list.name).to eq('Eltern der 4a')
      expect(klasse_4a.mailing_list.address(:long)).to eq('eltern-4a@schickhardt-gymnasium-herrenberg.de')
      expect(klasse_4a.mailing_list.url).to eq('/verteiler/eltern-4a')
    end

    it 'the parents mailing list has all parents as members' do
      expect(klasse_4a.mailing_list.members).to be
      expect(klasse_4a.mailing_list.members.size).to eq(2)
      expect(klasse_4a.mailing_list.members).to include(barry)
      expect(klasse_4a.mailing_list.members).to include(jerri)
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
    let(:pab) { Rolle.new(name: '1.EV').save }

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

    it 'has a mailing list for members of the PAB' do
      expect(klasse_4a.elternvertreter).to respond_to(:mailing_list)
      expect(klasse_4a.elternvertreter.mailing_list).to be
      expect(klasse_4a.elternvertreter.mailing_list.name).to eq('Elternvertreter der 4a')
      expect(klasse_4a.elternvertreter.mailing_list.address(:long)).to eq('elternvertreter-4a@schickhardt-gymnasium-herrenberg.de')
      expect(klasse_4a.elternvertreter.mailing_list.url).to eq('/verteiler/elternvertreter-4a')
      expect(klasse_4a.elternvertreter.mailing_list.members).to include(homer)
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

  context 'comparing instances' do
    subject(:klasse_8a) { described_class.new(stufe: '8', zug: 'a').save }
    subject(:klasse_9b) { described_class.new(stufe: '9', zug: 'b').save }
    subject(:klasse_9c) { described_class.new(stufe: '9', zug: 'c').save }
    subject(:klasse_10d) { described_class.new(stufe: '10', zug: 'd').save }
    subject(:klasse_j1) { described_class.new(stufe: 'j', zug: '1').save }
    subject(:klasse_j2) { described_class.new(stufe: 'j', zug: '2').save }

    it 'sorts by Stufe, then Zug' do
      klassen = [klasse_10d, klasse_j1, klasse_8a, klasse_9b, klasse_9c, klasse_j2].shuffle.sort
      expect(klassen.sort).to eq([klasse_8a, klasse_9b, klasse_9c, klasse_10d, klasse_j1, klasse_j2])
    end
  end
end
