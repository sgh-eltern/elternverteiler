# frozen_string_literal: true

require 'spec_helper'

require 'sgh/elternverteiler/lehrer_factory'

describe LehrerFactory do
  subject(:mapper) { described_class.new }

  context 'produces a Lehrer' do
    let(:attributes) { ['EK', 'Edna', 'Krabappel', 'E, Geo, NwT'] }
    let(:edna) { mapper.map(attributes) }
    let(:english) { Fach.new(kürzel: 'E', name: 'Englisch') }

    it 'with the expected lastname' do
      expect(edna.nachname).to eq('Edna')
    end

    it 'with the expected surname' do
      expect(edna.vorname).to eq('Krabappel')
    end

    it 'with the expected abbreviation' do
      expect(edna.kürzel).to eq('EK')
    end

    it 'with the expected mail' do
      expect(edna.email).to be_nil
    end

    it 'with the expected subjects' do
      expect(edna.fächer).to_not be_empty
      expect(edna.fächer.size).to eq(3)
      expect(edna.fächer[0].name).to eq('Englisch')
      expect(edna.fächer[1].name).to eq('Geografie')
      expect(edna.fächer[2].name).to eq('Naturwissenschaft und Technik')
    end
  end
end
