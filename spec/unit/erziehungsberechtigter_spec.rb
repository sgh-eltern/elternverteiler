# frozen_string_literal: true

require 'spec_helper'

describe Erziehungsberechtigter do
  subject(:homer) { described_class.new }

  context 'without data' do
    it 'there are no Erziehungsberechtigte' do
      expect(described_class.all).to be_empty
    end
  end

  context 'a valid Erziehungsberechtigter' do
    before do
      homer.nachname = 'Simpson'
      homer.save
    end

    it 'persists' do
      expect(homer).to be
      expect(homer.nachname).to eq('Simpson')
    end

    it 'can have a vorname' do
      homer.vorname = 'Homer'
      homer.save
      expect(homer.vorname).to eq('Homer')
    end

    it 'can have an empty vorname' do
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

    it 'can have a telefon' do
      homer.telefon = 'Homer'
      homer.save
      expect(homer.telefon).to eq('Homer')
    end

    it 'can have an empty telefon' do
      homer.telefon = ''
      homer.save
    end
  end
end
