# frozen_string_literal: true

require 'spec_helper'
require 'timecop'

describe Schüler do
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
      bart.klasse = '4a'
      bart.save
    end

    it 'persists' do
      expect(bart).to be
      expect(bart.vorname).to eq('Bart')
      expect(bart.nachname).to eq('Simpson')
      expect(bart.klasse).to eq('4a')
    end

    it 'has a created_at timestamp' do
      expect(bart.created_at).to be
    end

    it 'has a updated_at timestamp' do
      bart.save
      expect(bart.updated_at).to be
    end

    it 'updates the updated_at timestamp' do
      bart.save
      before_update = bart.updated_at

      Timecop.freeze(30) do
        bart.save
        expect(bart.updated_at).to be >= before_update
      end
    end
  end

  context 'missing attributes' do
    it 'cannot exist without vorname' do
      bart.nachname = 'Simpson'
      bart.klasse = '4a'
      expect { bart.save }.to raise_error(Sequel::NotNullConstraintViolation)
    end

    it 'cannot exist without nachname' do
      bart.vorname = 'Bart'
      bart.klasse = '4a'
      expect { bart.save }.to raise_error(Sequel::NotNullConstraintViolation)
    end

    it 'cannot exist without klasse' do
      bart.vorname = 'Bart'
      bart.nachname = 'Simpson'
      expect { bart.save }.to raise_error(Sequel::NotNullConstraintViolation)
    end
  end
end
