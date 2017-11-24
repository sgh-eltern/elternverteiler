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
    end

    it 'can have a first name' do
      homer.vorname = 'Homer'
      homer.save
      expect(homer.vorname).to eq('Homer')
    end

    it 'can have an empty first name' do
      homer.vorname = ''
      homer.save
    end

    it 'can have a mail' do
      homer.mail = 'Homer'
      homer.save
      expect(homer.mail).to eq('Homer')
    end

    it 'can have an empty mail' do
      homer.mail = ''
      homer.save
    end

    it 'can have a phone number' do
      homer.telefon = 'Homer'
      homer.save
      expect(homer.telefon).to eq('Homer')
    end

    it 'can have an empty phone number' do
      homer.telefon = ''
      homer.save
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
      expect(homer.ämter).to be_empty
    end
  end
end
