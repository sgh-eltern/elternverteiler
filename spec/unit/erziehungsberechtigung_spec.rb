# frozen_string_literal: true

require 'spec_helper'

describe Erziehungsberechtigung do
  let(:klassenstufe_4) { Klassenstufe.new(name: '4').save }
  let(:k4a) { Klasse.new(stufe: klassenstufe_4, zug: 'a').save }

  it 'has a forme namespace' do
    expect(subject.forme_namespace).to eq('sgh-elternverteiler-erziehungsberechtigung')
  end

  context 'the Simpsons' do
    let(:bart) { Schüler.new(vorname: 'Bart', nachname: 'Simpson', klasse: k4a).save }
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
      let(:klassenstufe_2) { Klassenstufe.new(name: '2').save }
      let(:k2a) { Klasse.new(stufe: klassenstufe_2, zug: 'a').save }
      let(:lisa) { Schüler.new(vorname: 'Lisa', nachname: 'Simpson', klasse: k2a).save }
      let(:marge) { Erziehungsberechtigter.new(vorname: 'Marge', nachname: 'Simpson').save }

      before do
        bart.add_eltern(marge)
        bart.add_eltern(homer)
        lisa.add_eltern(homer)
        lisa.add_eltern(marge)
      end

      it 'retains Homer and Marge because of Lisa' do
        bart.destroy
        expect(Erziehungsberechtigter.first!(vorname: 'Homer', nachname: 'Simpson')).to be
        expect(Erziehungsberechtigter.first!(vorname: 'Marge', nachname: 'Simpson')).to be
        expect(Schüler.first!(vorname: 'Lisa', nachname: 'Simpson')).to be
      end
    end
  end

  context 'the Van Houtens' do
    let(:milhouse) { Schüler.new(vorname: 'Milhouse', nachname: 'Van Houten', klasse: k4a).save }
    let(:luann) { Erziehungsberechtigter.new(vorname: 'Luann', nachname: 'Van Houten').save }
    let(:kirk) { Erziehungsberechtigter.new(vorname: 'Kirk', nachname: 'Van Houten').save }

    before do
      milhouse.add_eltern(luann)
      milhouse.add_eltern(kirk)
    end

    context "Milhouse' parents get divorced; Luann looses parentship; Milhouse stays with Kirk" do
      before do
        luann.destroy
      end

      it 'removes Luann from the parentship' do
        expect(Erziehungsberechtigter.first(nachname: 'Van Houten', vorname: 'Luann')).to be_nil
      end

      it "retains Kirk's parentship" do
        expect(Erziehungsberechtigter.first!(nachname: 'Van Houten', vorname: 'Kirk')).to be
      end

      it "shows just Kirk as Milhouse' parents" do
        expect(milhouse.eltern.count).to eq(1)
        expect(milhouse.eltern).to include(kirk)
        expect(milhouse.eltern).to_not include(luann)
      end
    end

    context 'Milhouse leaves the school' do
      it 'removes Luann and Kirk because they have no other kids in this school' do
        milhouse.destroy
        expect(Erziehungsberechtigter.where(nachname: 'Van Houten', vorname: 'Luann')).to be_empty
        expect(Erziehungsberechtigter.where(nachname: 'Van Houten', vorname: 'Kirk')).to be_empty
      end
    end
  end

  context 'a patchwork family' do
    let(:klassenstufe_7) { Klassenstufe.new(name: '7').save }
    let(:klassenstufe_10) { Klassenstufe.new(name: '10').save }
    let(:k7b) { Klasse.new(stufe: klassenstufe_7, zug: 'b').save }
    let(:k10c) { Klasse.new(stufe: klassenstufe_10, zug: 'c').save }

    let(:martina) { Erziehungsberechtigter.new(vorname: 'Martina', nachname: 'Bock').save }
    let(:thomas) { Erziehungsberechtigter.new(vorname: 'Thomas', nachname: 'Mustermann').save }
    let(:tajana) { Schüler.new(vorname: 'Tajana', nachname: 'Bock', klasse: k4a).save }
    let(:david) { Schüler.new(vorname: 'David', nachname: 'Mustermann', klasse: k7b).save }
    let(:mika) { Schüler.new(vorname: 'Mika', nachname: 'Bock', klasse: k10c).save }

    before do
      tajana.add_eltern(martina)
      david.add_eltern(thomas)
      mika.add_eltern(martina)
      mika.add_eltern(thomas)
    end

    context 'Tajana leaves school' do
      before do
        tajana.destroy
      end

      it 'retains Martina and Thomas because of Mika' do
        expect(Erziehungsberechtigter.first!(nachname: 'Bock', vorname: 'Martina')).to be
        expect(Erziehungsberechtigter.first!(nachname: 'Mustermann', vorname: 'Thomas')).to be
      end
    end

    context 'David leaves school' do
      before do
        david.destroy
      end

      it 'retains Martina and Thomas because of Mika' do
        expect(Erziehungsberechtigter.first!(nachname: 'Bock', vorname: 'Martina')).to be
        expect(Erziehungsberechtigter.first!(nachname: 'Mustermann', vorname: 'Thomas')).to be
      end
    end

    context 'Mika leaves school' do
      before do
        mika.destroy
      end

      it 'retains Martina and Thomas because of Tajana and David, respectively' do
        expect(Erziehungsberechtigter.first!(nachname: 'Bock', vorname: 'Martina')).to be
        expect(Erziehungsberechtigter.first!(nachname: 'Mustermann', vorname: 'Thomas')).to be
      end
    end

    context 'Tajana and David leave school' do
      before do
        tajana.destroy
        david.destroy
      end

      it 'retains Martina and Thomas because of Mika' do
        expect(Erziehungsberechtigter.first!(nachname: 'Bock', vorname: 'Martina')).to be
        expect(Erziehungsberechtigter.first!(nachname: 'Mustermann', vorname: 'Thomas')).to be
      end
    end

    context 'David and Mika leave school' do
      before do
        mika.destroy
        david.destroy
      end

      it 'retains Martina because of Tajana' do
        expect(Erziehungsberechtigter.first!(nachname: 'Bock', vorname: 'Martina')).to be
      end

      it 'destroys Thomas because he has no kid in school anymore' do
        expect(Erziehungsberechtigter.first(nachname: 'Mustermann', vorname: 'Thomas')).to_not be
      end
    end

    context 'Tajana and Mika leave school' do
      before do
        tajana.destroy
        mika.destroy
      end

      it 'retains Thomas because of David' do
        expect(Erziehungsberechtigter.first!(nachname: 'Mustermann', vorname: 'Thomas')).to be
      end

      it 'destroys Martina because she has no kid in school anymore' do
        expect(Erziehungsberechtigter.first(nachname: 'Bock', vorname: 'Martina')).to_not be
      end
    end
  end
end
