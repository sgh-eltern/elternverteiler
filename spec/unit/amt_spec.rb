# frozen_string_literal: true

require 'spec_helper'

describe Amt do
  let(:homer) { Erziehungsberechtigter.new(vorname: 'Homer', nachname: 'Simpson').save }
  let(:klasse_4a) { Klasse.new(stufe: '4', zug: 'a').save }
  let(:pab) { Rolle.new(name: 'Member of the Parent Advisory Board').save }

  context 'Homer is member of the PAB' do
    before do
      Amt.new(
        inhaber: homer,
        rolle: pab,
        klasse: klasse_4a
      ).save
    end

    it 'has a forme namespace' do
      expect(homer.ämter.first.forme_namespace).to eq('SGH--Elternverteiler--Amt')
    end

    it 'has a member of the PAB' do
      expect(klasse_4a.rollen).to include(pab)
    end

    it 'the PAB includes Homer' do
      expect(pab.mitglieder).to include(homer)
    end

    it 'lists the PAB as one of Homers roles' do
      expect(homer.rollen).to include(pab)
    end

    it 'shows the Amt on Homer' do
      expect(homer.ämter).not_to be_empty
      expect(homer.ämter.size).to eq(1)
      expect(homer.ämter.first.rolle).to eq(pab)
      expect(homer.ämter.first.to_s).to eq('Member of the Parent Advisory Board Klasse 4a')
    end

    context 'Chief Wiggum was also elected into the PAB' do
      let(:chief_wiggum) { Erziehungsberechtigter.new(vorname: 'Clancy', nachname: 'Wiggum').save }

      before do
        Amt.new(
          inhaber: chief_wiggum,
          rolle: pab,
          klasse: klasse_4a
          ).save
      end

      it 'has two members of the PAB' do
        expect(klasse_4a.rollen.count).to eq(2)
      end

      it 'the PAB includes Chief Wiggum' do
        expect(pab.mitglieder).to include(chief_wiggum)
      end

      it 'the PAB still includes Homer' do
        expect(pab.mitglieder).to include(homer)
      end

      it "lists the PAB as one of Chief Wiggum's roles" do
        expect(chief_wiggum.rollen).to include(pab)
      end

      it 'still lists the PAB as one of Homers roles' do
        expect(homer.rollen).to include(pab)
      end
    end

    context '5th grade has a PAB member' do
      let(:klasse_5a) { Klasse.new(stufe: '5', zug: 'a').save }
      let(:kyles_dad) { Erziehungsberechtigter.new(nachname: 'LaBianco', mail: 'kyle@labianco.com').save }

      before do
        Amt.new(
          inhaber: kyles_dad,
          rolle: pab,
          klasse: klasse_5a
        ).save
      end

      context '4th grade' do
        let(:pab_members) { Amt.where(klasse: klasse_4a, rolle: pab).map(&:inhaber) }

        it 'still lists Homer as member of the PAB' do
          expect(pab_members).to include(homer)
        end

        it "does not list Kyle's dad as member of the PAB" do
          expect(pab_members).to_not include(kyles_dad)
        end
      end

      context '5th grade' do
        let(:pab_members) { Amt.where(klasse: klasse_5a, rolle: pab).map(&:inhaber) }

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
        Amt.new(
          inhaber: homer,
          rolle: pab,
          klasse: klasse_4a
        ).save
      }.to raise_error(Sequel::UniqueConstraintViolation)
    end

    context '2th grade has a PAB member' do
      let(:klasse_2c) { Klasse.new(stufe: '2', zug: 'c').save }

      before do
        Amt.new(
          inhaber: homer,
          rolle: pab,
          klasse: klasse_2c
        ).save
      end

      it 'shows the Amt on Homer' do
        expect(homer.ämter.size).to eq(2)
        expect(homer.ämter.last.rolle).to eq(pab)
        expect(homer.ämter.last.to_s).to eq('Member of the Parent Advisory Board Klasse 2c')
      end
    end
  end
end
