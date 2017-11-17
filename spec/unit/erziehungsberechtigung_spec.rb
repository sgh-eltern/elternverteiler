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

      it "Homer is Bart's father" do
        expect(homer.kinder).to include(bart)
      end

      it "Bart is Homer's son" do
        expect(bart.eltern).to include(homer)
      end
    end

    context "when registering Homer as Bart's parent" do
      before do
        bart.add_eltern(homer)
      end

      it "Homer is Bart's father" do
        expect(homer.kinder).to include(bart)
      end

      it "Bart is Homer's son" do
        expect(bart.eltern).to include(homer)
      end
    end

    it "Homer is Bart's father" do
      expect(homer.kinder).to include(bart)
    end

    it "Bart is Homer's son" do
      expect(bart.eltern).to include(homer)
    end
  end
end
