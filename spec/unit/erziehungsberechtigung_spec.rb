# frozen_string_literal: true

require 'spec_helper'

describe Erziehungsberechtigung do
  context 'The Simpsons' do
    let(:bart) { Schüler.new(vorname: 'Bart', nachname: 'Simpson', klasse: '4a').save }
    let(:homer) { Erziehungsberechtigter.new(vorname: 'Homer', nachname: 'Simpson').save }

    context "when registering Bart as Homer's child" do
      before do
        homer.add_kinder(bart)
      end

      it "shows Homer as Bart's father" do
        expect(homer.kinder).to include(bart)
      end

      it "shows Bart as Homer's son" do
        expect(bart.eltern).to include(homer)
      end
    end

    context "when registering Homer as Bart's parent" do
      before do
        bart.add_eltern(homer)
      end

      it "shows Homer as Bart's father" do
        expect(homer.kinder).to include(bart)
      end

      it "shows Bart as Homer's son" do
        expect(bart.eltern).to include(homer)
      end
    end

    context 'Bart is thrown off the school' do
      let(:lisa) { Schüler.new(vorname: 'Lisa', nachname: 'Simpson', klasse: '2a').save }
      let(:marge) { Erziehungsberechtigter.new(vorname: 'Marge', nachname: 'Simpson').save }

      before do
        bart.add_eltern(marge)
        bart.add_eltern(homer)
        lisa.add_eltern(homer)
        lisa.add_eltern(marge)
      end

      it 'keeps Homer and Marge because of Lisa' do
        Schüler.find(nachname: 'Simpson', vorname: 'Bart').delete
        expect(Erziehungsberechtigter.find(vorname: 'Homer', nachname: 'Simpson')).to be
        expect(Erziehungsberechtigter.find(vorname: 'Marge', nachname: 'Simpson')).to be
        expect(Schüler.find(vorname: 'Lisa', nachname: 'Simpson')).to be
      end
    end

    context 'Milhouse leaves the school' do
      let(:milhouse) { Schüler.new(vorname: 'Milhouse', nachname: 'Van Houten', klasse: '4a').save }
      let(:luann) { Erziehungsberechtigter.new(vorname: 'Luann', nachname: 'Van Houten').save }
      let(:kirk) { Erziehungsberechtigter.new(vorname: 'Kirk', nachname: 'Van Houten').save }

      before do
        milhouse.add_eltern(luann)
        milhouse.add_eltern(kirk)
      end

      it 'removes Luann and Kirk because they have no other kids in this school' do
        Schüler.find(nachname: 'Van Houten', vorname: 'Milhouse').delete
        expect(Erziehungsberechtigter.find(nachname: 'Van Houten', vorname: 'Luann')).to be_nil
        expect(Erziehungsberechtigter.find(nachname: 'Van Houten', vorname: 'Kirk')).to be_nil
      end
    end
  end
end
