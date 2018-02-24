# frozen_string_literal: true

require 'spec_helper'
require 'timecop'

describe Schüler do
  subject(:bart) { described_class.new }
  let(:k4a) { Klasse.new(stufe: '4', zug: 'a').save }

  context 'a valid pupil' do
    before do
      bart.vorname = 'Bart'
      bart.nachname = 'Simpson'
      bart.klasse = k4a
      bart.save
      bart.refresh
    end

    it 'persists' do
      expect(bart).to be
      expect(bart.vorname).to eq('Bart')
      expect(bart.nachname).to eq('Simpson')
      expect(bart.klasse).to eq(k4a)
      expect(bart.name).to eq('Simpson, Bart')
    end

    it 'has a string representation' do
      expect(bart.to_s).to eq('Bart Simpson, 4a')
    end

    it 'has a forme namespace' do
      expect(bart.forme_namespace).to eq('sgh-elternverteiler-schüler')
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
    it 'cannot exist without first name' do
      bart.nachname = 'Simpson'
      bart.klasse = k4a
      expect { bart.save }.to raise_error(Sequel::NotNullConstraintViolation)
    end

    it 'cannot exist without last name' do
      bart.vorname = 'Bart'
      bart.klasse = k4a
      expect { bart.save }.to raise_error(Sequel::NotNullConstraintViolation)
    end

    it 'cannot exist without grade' do
      bart.vorname = 'Bart'
      bart.nachname = 'Simpson'
      expect { bart.save }.to raise_error(Sequel::NotNullConstraintViolation)
    end
  end
end
