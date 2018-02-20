# frozen_string_literal: true

require 'spec_helper'

describe Erziehungsberechtigter do
  subject(:homer) { described_class.new }

  context 'an ordinary parent' do
    it 'persists' do
      homer.nachname = 'Simpson'
      homer.save
      homer.refresh
      expect(homer.nachname).to eq('Simpson')
      expect(homer.name).to eq('Simpson')
    end

    it 'may have a first name' do
      homer.nachname = 'Simpson'
      homer.vorname = 'Homer'
      homer.save
      expect(homer.vorname).to eq('Homer')
      expect(homer.name).to eq('Simpson, Homer')
    end

    it 'may have an empty first name' do
      homer.vorname = ''
      homer.mail = 'Homer'
      homer.save
    end

    it 'may have a mail address' do
      homer.mail = 'Homer'
      homer.save
      expect(homer.mail).to eq('Homer')
    end

    it 'may have an empty mail if lastname is present' do
      homer.nachname = 'Simpson'
      homer.mail = ''
      homer.save
    end

    it 'may have a phone number' do
      homer.nachname = 'Simpson'
      homer.telefon = 'Homer'
      homer.save
      expect(homer.telefon).to eq('Homer')
    end

    it 'must have at least a last name' do
      expect { homer.save }.to raise_error(Erziehungsberechtigter::ValidationError)
    end

    it 'can have an empty phone number if lastname is present' do
      homer.nachname = 'Simpson'
      homer.telefon = ''
      homer.save
    end

    it 'has a forme namespace' do
      expect(homer.forme_namespace).to eq('SGH--Elternverteiler--Erziehungsberechtigter')
    end

    context 'without an email address' do
      before do
        homer.nachname = 'Simpson'
        homer.vorname = 'Homer'
      end

      it 'has a string representation' do
        expect(homer.to_s).to eq('Homer Simpson')
      end
    end

    context 'with just an email address' do
      before do
        homer.mail = 'homer@thesimpsons.org'
        homer.save
      end

      it 'has a string representation' do
        expect(homer.to_s).to eq('homer@thesimpsons.org')
      end
    end

    context 'with first and last name and an email address' do
      before do
        homer.vorname = 'Homer'
        homer.nachname = 'Simpson'
        homer.mail = 'homer@thesimpsons.org'
        homer.save
      end

      it 'has a string representation' do
        expect(homer.to_s).to eq('Homer Simpson <homer@thesimpsons.org>')
      end
    end

    it 'has no roles' do
      expect(homer.rollen).to be_empty
    end

    it 'has no Ämter' do
      expect(homer.ämter).to be_empty
    end
  end
end
