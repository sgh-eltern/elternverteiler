# frozen_string_literal: true

require 'spec_helper'

describe Erziehungsberechtigung do
  context 'the Simpsons' do
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

      it 'retains Homer and Marge because of Lisa' do
        bart.destroy
        expect(Erziehungsberechtigter.find(vorname: 'Homer', nachname: 'Simpson')).to be
        expect(Erziehungsberechtigter.find(vorname: 'Marge', nachname: 'Simpson')).to be
        expect(Schüler.find(vorname: 'Lisa', nachname: 'Simpson')).to be
      end
    end
  end

  context 'the Van Houtens' do
    let(:milhouse) { Schüler.new(vorname: 'Milhouse', nachname: 'Van Houten', klasse: '4a').save }
    let(:luann) { Erziehungsberechtigter.new(vorname: 'Luann', nachname: 'Van Houten').save }
    let(:kirk) { Erziehungsberechtigter.new(vorname: 'Kirk', nachname: 'Van Houten').save }

    before do
      milhouse.add_eltern(luann)
      milhouse.add_eltern(kirk)
    end

    context "Milhouse' parents get divorced; Milhouse stays with Kirk" do
      before do
        luann.destroy
      end

      it "retains Kirk's parentship" do
        expect(Erziehungsberechtigter.find(nachname: 'Van Houten', vorname: 'Kirk')).to be
      end

      it "removes Luann from the parentship" do
        expect(Erziehungsberechtigter.find(nachname: 'Van Houten', vorname: 'Luann')).to be_nil
      end

      it "shows just Kirk as Milhouse' parents" do
        expect(milhouse.eltern.count).to eq(1)
        expect(milhouse.eltern).to include(kirk)
        expect(milhouse.eltern).to_not include(luann)
      end
    end
  end
end
