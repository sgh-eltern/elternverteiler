# frozen_string_literal: true

require 'spec_helper'

describe Klasse do
  context 'Jahrgangsstufe' do
    let(:stufe) { Klassenstufe.new(name: 'J1').save }

    it 'Zug may be empty' do
      expect { Klasse.new(stufe: stufe, zug: '').save }.not_to raise_error
    end

    it 'Zug may be nil' do
      expect { Klasse.new(stufe: stufe).save }.not_to raise_error
    end

    it 'must not allow a duplicate class' do
      expect { Klasse.new(stufe: stufe).save }.not_to raise_error
      expect { Klasse.new(stufe: stufe).save }.to raise_error(Sequel::ValidationFailed)
    end
  end

  context 'Mittelstufe' do
    let(:stufe) { Klassenstufe.new(name: '9').save }

    it 'Zug may not be empty' do
      expect { Klasse.new(stufe: stufe, zug: '').save }.to raise_error(Sequel::ValidationFailed)
    end

    it 'Zug may not be nil' do
      expect { Klasse.new(stufe: stufe).save }.to raise_error(Sequel::ValidationFailed)
    end
  end

  describe 'Comparing instances' do
    let(:klassenstufe_8)  {  Klassenstufe.new(name: '8').save }
    let(:klassenstufe_9)  {  Klassenstufe.new(name: '9').save }
    let(:klassenstufe_10) {  Klassenstufe.new(name: '10').save }
    let(:klassenstufe_j1)  {  Klassenstufe.new(name: 'J1').save }
    let(:klassenstufe_j2)  {  Klassenstufe.new(name: 'J2').save }

    subject(:klasse_8a)  { Klasse.new(stufe: klassenstufe_8,  zug: 'a').save }
    subject(:klasse_9b)  { Klasse.new(stufe: klassenstufe_9,  zug: 'b').save }
    subject(:klasse_9c)  { Klasse.new(stufe: klassenstufe_9,  zug: 'c').save }
    subject(:klasse_10d) { Klasse.new(stufe: klassenstufe_10, zug: 'd').save }
    subject(:klasse_j1)  { Klasse.new(stufe: klassenstufe_j1).save }
    subject(:klasse_j2)  { Klasse.new(stufe: klassenstufe_j2).save }

    it 'sorts by Stufe, then Zug' do
      klassen = [klasse_10d, klasse_j1, klasse_8a, klasse_9b, klasse_9c, klasse_j2].shuffle
      expect(klassen.sort).to eq([klasse_8a, klasse_9b, klasse_9c, klasse_10d, klasse_j1, klasse_j2])
    end
  end

  context 'Klasse 4A' do
    subject(:klasse_4a) { Klasse.new(stufe: klassenstufe_4, zug: 'a').save }
    let(:klassenstufe_4) { Klassenstufe.new(name: '4').save }

    it 'has a string representation' do
      expect(klasse_4a.to_s).to eq('Klasse 4a')
    end

    it 'has a name' do
      expect(klasse_4a.name).to eq('4a')
    end

    context 'Sherri and Terri are in 4A' do
      let(:sherri) { Schüler.new(vorname: 'Sherri', nachname: 'Mackleberry', klasse: klasse_4a).save }
      let(:terri) { Schüler.new(vorname: 'Terri', nachname: 'Mackleberry', klasse: klasse_4a).save }
      let(:jerri) { Erziehungsberechtigter.new(vorname: 'Jerri', nachname: 'Mackleberry', mail: 'jerri@mackleberry.org').save }
      let(:barry) { Erziehungsberechtigter.new(vorname: 'Barry', nachname: 'Mackleberry', mail: 'barry@mackleberry.org').save }

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
        expect(klasse_4a.mailing_list.name).to eq('Eltern der Klasse 4a')
        expect(klasse_4a.mailing_list.address(:long)).to eq('eltern-4a@schickhardt-gymnasium-herrenberg.de')
        expect(klasse_4a.mailing_list.url).to eq('/verteiler/eltern-4a')
      end

      it 'the parents mailing list has their parents as members' do
        expect(klasse_4a.mailing_list.members).to be
        expect(klasse_4a.mailing_list.members.size).to eq(2)
        expect(klasse_4a.mailing_list.members).to include(barry)
        expect(klasse_4a.mailing_list.members).to include(jerri)
      end

      context '4a graduates' do
        before { klasse_4a.destroy }

        it 'removes the class itself' do
          expect { klasse_4a.reload }.to raise_error(Sequel::NoExistingObject)
          expect(Klasse.find(stufe: klassenstufe_4)).to_not be
        end

        it 'removes all pupils' do
          expect { sherri.reload }.to raise_error(Sequel::NoExistingObject)
          expect(Schüler.where(vorname: 'Sherri', nachname: 'Mackleberry')).to be_empty
          expect { terri.reload }.to raise_error(Sequel::NoExistingObject)
          expect(Schüler.where(vorname: 'Terri', nachname: 'Mackleberry')).to be_empty
        end

        it 'removes both parents from the database' do
          expect(Erziehungsberechtigter.first(vorname: 'Barry', nachname: 'Mackleberry')).to be_nil
          expect { barry.reload }.to raise_error(Sequel::NoExistingObject)
          expect(Erziehungsberechtigter.first(vorname: 'Jerri', nachname: 'Mackleberry')).to be_nil
          expect { jerri.reload }.to raise_error(Sequel::NoExistingObject)
        end

        xit "removes both parents from the class' mailing list" do
          expect(klasse_4a.mailing_list.members).to_not include(jerri)
          expect(klasse_4a.mailing_list.members).to_not include(barry)
        end
      end

      context 'some 5th graders with their parents' do
        let(:klassenstufe_5) { Klassenstufe.new(name: '5').save }
        let(:k5a) { Klasse.new(stufe: klassenstufe_5, zug: 'a').save }
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

    context 'Homer is sent to the PAB' do
      let(:homer) { Erziehungsberechtigter.new(vorname: 'Homer', nachname: 'Simpson').save }
      let(:pab) { Amt.new(name: 'Klassenelternvertreter').save }

      before do
        Amtsperiode.new(
          inhaber: homer,
          amt: pab,
          klasse: klasse_4a
        ).save
      end

      it 'lists parents with roles' do
        expect(klasse_4a.ämter.size).to eq(1)
      end

      it 'lists the PAB as one of the roles' do
        expect(klasse_4a.ämter).to include(pab)
      end

      it 'has a mailing list for members of the PAB' do
        expect(klasse_4a.elternvertreter).to respond_to(:mailing_list)
        expect(klasse_4a.elternvertreter.mailing_list).to be
        expect(klasse_4a.elternvertreter.mailing_list.name).to eq('Elternvertreter der Klasse 4a')
        expect(klasse_4a.elternvertreter.mailing_list.address(:long)).to eq('elternvertreter-4a@schickhardt-gymnasium-herrenberg.de')
        expect(klasse_4a.elternvertreter.mailing_list.url).to eq('/verteiler/elternvertreter-4a')
        expect(klasse_4a.elternvertreter.mailing_list.members).to include(homer)
      end

      context 'Klasse 2A sends Marge to the PAB' do
        subject(:klasse_2a) { Klasse.new(stufe: klassenstufe_2, zug: 'a').save }
        let(:marge) { Erziehungsberechtigter.new(vorname: 'Marge', nachname: 'Simpson').save }
        let(:klassenstufe_2) { Klassenstufe.new(name: '2').save }

        before do
          Amtsperiode.new(
            inhaber: marge,
            amt: pab,
            klasse: klasse_2a
          ).save
        end

        it 'lists one holder of a role in this class' do
          expect(klasse_2a.ämter.size).to eq(1)
        end

        it 'has both Marge and Homer as members of the PAB' do
          expect(pab.inhaber.size).to eq(2)
          expect(pab.inhaber).to include(marge)
          expect(pab.inhaber).to include(homer)
        end

        it 'lists Marge as PAB member' do
          expect(pab.inhaber).to include(marge)
        end
      end
    end

    context 'Parents have two kids in different classes' do
      # let(:klassenstufe_4) { Klassenstufe.new(name: '4').save }
      # let(:klasse_4a) { Klasse.new(stufe: klassenstufe_4, zug: 'a').save }
      let(:bart) { Schüler.new(vorname: 'Bart', nachname: 'Simpson', klasse: klasse_4a).save }
      let(:klassenstufe_2) { Klassenstufe.new(name: '2').save }
      let(:klasse_2a) { Klasse.new(stufe: klassenstufe_2, zug: 'a').save }
      let(:lisa) { Schüler.new(vorname: 'Lisa', nachname: 'Simpson', klasse: klasse_2a).save }
      let(:homer) { Erziehungsberechtigter.new(vorname: 'Homer', nachname: 'Simpson').save }
      let(:marge) { Erziehungsberechtigter.new(vorname: 'Marge', nachname: 'Simpson').save }

      before do
        bart.add_eltern(homer)
        bart.add_eltern(marge)
        lisa.add_eltern(homer)
        lisa.add_eltern(marge)
      end

      context "Bart's class is dissolved" do
        before { klasse_4a.destroy }

        it 'removes the class itself' do
          expect { klasse_4a.reload }.to raise_error(Sequel::NoExistingObject)
          expect(Klasse.where(stufe: klassenstufe_4, zug: 'a')).to be_empty
        end

        it 'removes all pupils (Bart)' do
          expect { bart.reload }.to raise_error(Sequel::NoExistingObject)
          expect(Schüler.where(vorname: 'Bart', nachname: 'Simpson')).to be_empty
        end

        it 'does not remove Homer and Marge, because Lisa is still here' do
          expect(homer.reload).to be
          expect(marge.reload).to be
        end

        xit "removes both parents from the class' mailing list" do
          expect(klasse_4a.mailing_list.members).to_not include(homer)
          expect(klasse_4a.mailing_list.members).to_not include(marge)
        end

        it 'removes Homer from the PAB'
      end
    end

    it 'cannot create another Klasse with the same stufe and zug' do
      expect do
        Klasse.new(stufe: klasse_4a.stufe, zug: klasse_4a.zug).save
      end.to raise_error(Sequel::UniqueConstraintViolation)
    end

    it 'cannot create another Klasse with the same stufe and zug' do
      expect do
        Klasse.new(stufe: klasse_4a.stufe, zug: klasse_4a.zug).save
      end.to raise_error(Sequel::UniqueConstraintViolation)
    end

    it 'cannot create another Klasse with the same Klassenstufe and the same Zug in swapcase' do
      expect do
        Klasse.new(stufe: klasse_4a.stufe, zug: klasse_4a.zug.swapcase).save
      end.to raise_error(Sequel::ValidationFailed)
    end

    it 'can create another Klasse with the same stufe, but another zug' do
      expect do
        Klasse.new(stufe: klasse_4a.stufe, zug: klasse_4a.zug.next).save
      end.not_to raise_error
    end

    it 'can create another Klasse with another stufe, but the same zug' do
      klassenstufe_next = Klassenstufe.new(name: klasse_4a.stufe.ordinal.next).save

      expect do
        Klasse.new(stufe: klassenstufe_next, zug: klasse_4a.zug).save
      end.not_to raise_error
    end
  end

  it 'has a forme namespace' do
    expect(described_class.new.forme_namespace).to eq('sgh-elternverteiler-klasse')
  end
end
