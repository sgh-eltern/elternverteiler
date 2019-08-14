# frozen_string_literal: true

require 'spec_helper'

describe 'Lehrer <=> Fächer' do
  let(:edna) { Lehrer.create(vorname: 'Edna', nachname: 'Krabappel') }
  let(:english) { Fach.create(name: 'English', kürzel: 'E') }

  shared_examples 'Edna is an English teacher' do
    it "English is one of Edna's subjects" do
      expect(edna.fächer).to include(english)
    end

    it 'Edna is a teacher of English' do
      expect(english.lehrer).to include(edna)
    end
  end

  context 'Registering English as subject teached by Edna' do
    before do
      edna.add_fächer(english)
    end
    include_examples 'Edna is an English teacher'
  end

  context 'Registering Edna as teacher of English' do
    before do
      english.add_lehrer(edna)
    end
    include_examples 'Edna is an English teacher'
  end

  context 'English is not teached anymore' do
    before do
      english.destroy
      edna.reload
    end

    it 'keeps the teacher' do
      expect(edna).to be
    end

    it 'the teacher has no subjects anymore' do
      expect(edna.fächer).to be_empty
    end
  end

  context 'Edna dies' do
    before do
      edna.destroy
      english.reload
    end

    it 'keeps the subject itself' do
      expect(english).to be
    end

    it 'the subject has no teachers anymore' do
      expect(english.lehrer).to be_empty
    end
  end

  context 'Edna teaches English and French' do
    let(:french) { Fach.create(name: 'French', kürzel: 'F') }

    before do
      edna.add_fächer(english)
      edna.add_fächer(french)
    end

    it 'lists both subjects for Edna' do
      expect(edna.fächer).to include(english)
      expect(edna.fächer).to include(french)
    end

    context 'but stops doing English' do
      before do
        edna.remove_fächer(english)
      end

      it 'only lists French as her subject' do
        expect(edna.fächer).to eq [french]
      end
    end
  end
end
