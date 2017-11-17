# frozen_string_literal: true

require 'spec_helper'
require 'sgh/elternverteiler/schüler'

describe SGH::Elternverteiler::Schüler do
  subject(:bart) { described_class.new }

  context 'without data' do
    it 'there are no Schüler' do
      expect(described_class.all).to be_empty
    end
  end

  context 'a valid Schüler' do
    before do
      bart.vorname = 'Bart'
      bart.nachname = 'Simpson'
      bart.klasse = '5a'
      bart.save
    end

    it 'persists' do
      expect(bart).to be
      expect(bart.vorname).to eq('Bart')
      expect(bart.nachname).to eq('Simpson')
      expect(bart.klasse).to eq('5a')
    end
  end

  context 'missing attributes' do
    it 'cannot exist without vorname' do
      bart.nachname = 'Simpson'
      bart.klasse = '5a'
      expect{bart.save}.to raise_error(Sequel::NotNullConstraintViolation)
    end

    it 'cannot exist without nachname' do
      bart.vorname = 'Bart'
      bart.klasse = '5a'
      expect{bart.save}.to raise_error(Sequel::NotNullConstraintViolation)
    end

    it 'cannot exist without klasse' do
      bart.vorname = 'Bart'
      bart.nachname = 'Simpson'
      expect{bart.save}.to raise_error(Sequel::NotNullConstraintViolation)
    end
  end
end
