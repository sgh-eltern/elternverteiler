# frozen_string_literal: true

describe Klassenstufe do
  subject(:klassenstufe_4) { Klassenstufe.new(name: '4').save }

  it 'has a string representation' do
    expect(klassenstufe_4.to_s).to eq('Klassenstufe 4')
  end

  it 'has a name' do
    expect(klassenstufe_4.name).to eq('4')
  end

  it 'has an ordinal' do
    expect(klassenstufe_4.ordinal).to eq(4)
  end

  it 'has a forme namespace' do
    expect(klassenstufe_4.forme_namespace).to eq('sgh-elternverteiler-klassenstufe')
  end

  it 'cannot create another one with the same name' do
    expect do
      Klassenstufe.new(name: subject.name).save
    end.to raise_error(Sequel::UniqueConstraintViolation)
  end

  it 'has an empty mailing list' do
    expect(klassenstufe_4.mailing_list).to be
    expect(klassenstufe_4.mailing_list.name).to eq('Eltern der Klassenstufe 4')
    expect(klassenstufe_4.mailing_list.address(:long)).to eq('eltern-4@schickhardt-gymnasium-herrenberg.de')
    expect(klassenstufe_4.mailing_list.url).to eq('/verteiler/eltern-4')
    expect(klassenstufe_4.mailing_list.members).to be_empty
  end

  context 'Klasse 4a and 4b exist' do
    let(:klasse_4a) { Klasse.new(stufe: klassenstufe_4, zug: 'a').save }
    let(:klasse_4b) { Klasse.new(stufe: klassenstufe_4, zug: 'b').save }

    let(:sherri) { Schüler.new(vorname: 'Sherri', nachname: 'Mackleberry', klasse: klasse_4a).save }
    let(:terri) { Schüler.new(vorname: 'Terri', nachname: 'Mackleberry', klasse: klasse_4b).save }
    let(:jerri) { Erziehungsberechtigter.new(vorname: 'Jerri', nachname: 'Mackleberry', mail: 'jerri@mackleberry.org').save }
    let(:barry) { Erziehungsberechtigter.new(nachname: 'Mackleberry', mail: 'barry@mackleberry.org').save }

    before do
      sherri.add_eltern(jerri)
      sherri.add_eltern(barry)
      terri.add_eltern(jerri)
      terri.add_eltern(barry)
    end

    it 'has Klassen' do
      expect(subject.klassen).to include(klasse_4a)
      expect(subject.klassen).to include(klasse_4b)
    end

    it 'has Schüler' do
      expect(klassenstufe_4).to respond_to(:schüler)
      expect(klassenstufe_4.schüler.count).to eq(2)
      expect(klassenstufe_4.schüler).to include(sherri)
      expect(klassenstufe_4.schüler).to include(terri)
    end

    context 'mailing list' do
      let(:mailing_list) { klassenstufe_4.mailing_list }

      it 'has a mailing list for them' do
        expect(mailing_list).to be
        expect(mailing_list.name).to eq('Eltern der Klassenstufe 4')
        expect(mailing_list.address(:long)).to eq('eltern-4@schickhardt-gymnasium-herrenberg.de')
        expect(mailing_list.url).to eq('/verteiler/eltern-4')
      end

      it 'has all parents as members of the mailing list' do
        expect(mailing_list.members).to be
        expect(mailing_list.members.size).to eq(2)
        expect(mailing_list.members).to include(barry)
        expect(mailing_list.members).to include(jerri)
      end
    end

    context 'Elternvertreter' do
      let(:pab) { Amt.new(name: '1.EV').save }

      before do
        Amtsperiode.new(inhaber: jerri, amt: pab, klasse: klasse_4a).save
        Amtsperiode.new(inhaber: barry, amt: pab, klasse: klasse_4b).save
      end

      let(:elternvertreter) { klassenstufe_4.elternvertreter }

      it 'lists all Elternvertreter of the Klassenstufe' do
        expect(elternvertreter).to be
      end

      context 'mailing list' do
        let(:mailing_list) { elternvertreter.mailing_list }

        it 'has a mailing list for Elternvertreter' do
          expect(mailing_list).to be
          expect(mailing_list.name).to eq('Elternvertreter der Klassenstufe 4')
          expect(mailing_list.address(:long)).to eq('elternvertreter-4@schickhardt-gymnasium-herrenberg.de')
          expect(mailing_list.url).to eq('/verteiler/elternvertreter-4')
        end

        it 'the Elternvertreter mailing list has all parents as members' do
          expect(mailing_list.members).to be
          expect(mailing_list.members.size).to eq(2)
          expect(mailing_list.members).to include(barry)
          expect(mailing_list.members).to include(jerri)
        end
      end
    end
  end

  context 'Jahrgangsstufe 1' do
    subject { Klassenstufe.new(name: 'J1').save }

    it 'has an ordinal' do
      expect(subject.ordinal).to eq(11)
    end
  end

  context 'comparing instances' do
    let(:klassenstufe_8)  {  Klassenstufe.new(name: '8').save }
    let(:klassenstufe_9)  {  Klassenstufe.new(name: '9').save }
    let(:klassenstufe_10) {  Klassenstufe.new(name: '10').save }
    let(:klassenstufe_j1)  {  Klassenstufe.new(name: 'J1').save }
    let(:klassenstufe_j2)  {  Klassenstufe.new(name: 'J2').save }

    it 'sorts numerically' do
      klassenstufen = [klassenstufe_8, klassenstufe_9, klassenstufe_10, klassenstufe_j1, klassenstufe_j2].shuffle
      expect(klassenstufen.sort).to eq([klassenstufe_8, klassenstufe_9, klassenstufe_10, klassenstufe_j1, klassenstufe_j2])
    end
  end
end
