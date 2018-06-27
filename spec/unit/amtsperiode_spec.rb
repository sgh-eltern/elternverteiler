# frozen_string_literal: true

describe Amtsperiode do
  let(:homer) { Erziehungsberechtigter.new(vorname: 'Homer', nachname: 'Simpson').save }
  let(:klassenstufe_4) { Klassenstufe.new(name: '4').save }
  let(:klasse_4a) { Klasse.new(stufe: klassenstufe_4, zug: 'a').save }
  let(:pab) { Amt.new(name: 'Member of the Parent Advisory Board').save }

  context 'Homer is member of the PAB' do
    before do
      Amtsperiode.new(
        inhaber: homer,
        amt: pab,
        klasse: klasse_4a
      ).save
    end

    it 'has a forme namespace' do
      expect(homer.amtsperioden.first.forme_namespace).to eq('sgh-elternverteiler-amtsperiode')
    end

    it 'has a member of the PAB' do
      expect(klasse_4a.ämter).to include(pab)
    end

    it 'the PAB includes Homer' do
      expect(pab.mitglieder).to include(homer)
    end

    it 'lists the PAB as one of Homers roles' do
      expect(homer.ämter).to include(pab)
    end

    it 'shows the Amtsperiode on Homer' do
      expect(homer.amtsperioden).not_to be_empty
      expect(homer.amtsperioden.size).to eq(1)
      expect(homer.amtsperioden.first.amt).to eq(pab)
      expect(homer.amtsperioden.first.to_s).to eq('Member of the Parent Advisory Board Klasse 4a')
    end

    context 'Chief Wiggum was also elected into the PAB' do
      let(:chief_wiggum) { Erziehungsberechtigter.new(vorname: 'Clancy', nachname: 'Wiggum').save }

      before do
        Amtsperiode.new(
          inhaber: chief_wiggum,
          amt: pab,
          klasse: klasse_4a
          ).save
      end

      it 'has two members of the PAB' do
        expect(klasse_4a.ämter.count).to eq(2)
      end

      it 'the PAB includes Chief Wiggum' do
        expect(pab.mitglieder).to include(chief_wiggum)
      end

      it 'the PAB still includes Homer' do
        expect(pab.mitglieder).to include(homer)
      end

      it "lists the PAB as one of Chief Wiggum's roles" do
        expect(chief_wiggum.ämter).to include(pab)
      end

      it 'still lists the PAB as one of Homers roles' do
        expect(homer.ämter).to include(pab)
      end
    end

    context '5th grade has a PAB member' do
      let(:klassenstufe_5) { Klassenstufe.new(name: '5').save }
      let(:klasse_5a) { Klasse.new(stufe: klassenstufe_5, zug: 'a').save }
      let(:kyles_dad) { Erziehungsberechtigter.new(nachname: 'LaBianco', mail: 'kyle@labianco.com').save }

      before do
        Amtsperiode.new(
          inhaber: kyles_dad,
          amt: pab,
          klasse: klasse_5a
        ).save
      end

      context '4th grade' do
        let(:pab_members) { Amtsperiode.where(klasse: klasse_4a, amt: pab).map(&:inhaber) }

        it 'still lists Homer as member of the PAB' do
          expect(pab_members).to include(homer)
        end

        it "does not list Kyle's dad as member of the PAB" do
          expect(pab_members).to_not include(kyles_dad)
        end
      end

      context '5th grade' do
        let(:pab_members) { Amtsperiode.where(klasse: klasse_5a, amt: pab).map(&:inhaber) }

        it 'has a member of the PAB' do
          expect(pab_members).to include(kyles_dad)
        end

        it 'does not list Homer as member of the PAB' do
          expect(pab_members).to_not include(homer)
        end
      end
    end

    it 'it refuses to add Homer twice as member of the PAB' do
      expect {
        Amtsperiode.new(
          inhaber: homer,
          amt: pab,
          klasse: klasse_4a
        ).save
      }.to raise_error(Sequel::UniqueConstraintViolation)
    end

    context '2th grade has a PAB member' do
      let(:klassenstufe_2) { Klassenstufe.new(name: '2').save }
      let(:klasse_2c) { Klasse.new(stufe: klassenstufe_2, zug: 'c').save }

      before do
        Amtsperiode.new(
          inhaber: homer,
          amt: pab,
          klasse: klasse_2c
        ).save
      end

      it 'shows the Amtsperiode on Homer' do
        expect(homer.amtsperioden.size).to eq(2)
        expect(homer.amtsperioden.last.amt).to eq(pab)
        expect(homer.amtsperioden.last.to_s).to eq('Member of the Parent Advisory Board Klasse 2c')
      end
    end
  end
end
