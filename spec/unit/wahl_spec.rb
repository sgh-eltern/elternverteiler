# frozen_string_literal: true

require 'spec_helper'

describe Wahl do
  let(:homer) { Erziehungsberechtigter.new(vorname: 'Homer', nachname: 'Simpson').save }
  let(:klasse_4a) { Klasse.new(stufe: '4', zug: 'a').save }
  let(:pab) { Rolle.new(name: 'Member of the Parent Advisory Board').save }

  context 'Homer is member of the PAB' do
    before do
      Wahl.new(
        erziehungsberechtigter: homer,
        rolle: pab,
        klasse: klasse_4a
      ).save
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

    context 'Chief Wiggum was also elected into the PAB' do
      let(:chief_wiggum) { Erziehungsberechtigter.new(vorname: 'Clancy', nachname: 'Wiggum').save }

      before do
        Wahl.new(
          erziehungsberechtigter: chief_wiggum,
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

      let(:wahl) { Wahl.new(
        erziehungsberechtigter: kyles_dad,
        rolle: pab,
        klasse: klasse_5a
        ).save
      }

      context '4th grade' do
        it 'has a member of the PAB' do
          expect(klasse_4a.rollen).to include(pab)
        end

        it "does not list Kyle's dad as member of the PAB" do
          expect(klasse_4a.rollen).to_not include(kyles_dad)
        end
      end

      context '5th grade' do
        it 'has a member of the PAB' do
          expect(klasse_5a.rollen).to_not include(pab)
        end

        it 'does not list Homer as member of the PAB' do
          expect(klasse_5a.rollen).to_not include(homer)
        end
      end
    end

    it 'it refuses to add Homer twice as member of the PAB' do
      expect {
        Wahl.new(
          erziehungsberechtigter: homer,
          rolle: pab,
          klasse: klasse_4a
        ).save
      }.to raise_error(Sequel::UniqueConstraintViolation)
    end
  end
end
