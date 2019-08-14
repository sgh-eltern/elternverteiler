# frozen_string_literal: true

require 'spec_helper'

require 'sgh/elternverteiler/lehrer-diff/persister'

describe LehrerDiff::Persister do
  subject(:edna) { Lehrer.first(kürzel: 'ek') }

  let(:attributes) {
    OpenStruct.new(
      kürzel: 'ek',
      vorname: 'Edna',
      nachname: 'Krabappel',
      fächer: %w[E Geo NwT],
    )
  }

  let(:english) { Fach.new(kürzel: 'E', name: 'Englisch') }

  before do
    described_class.new.save(attributes)
  end

  it 'persists' do
    expect(edna).to be
  end

  it 'has persisted the expected lastname' do
    expect(edna.nachname).to eq('Krabappel')
  end

  it 'has persisted the expected surname' do
    expect(edna.vorname).to eq('Edna')
  end

  it 'has persisted the expected abbreviation' do
    expect(edna.kürzel).to eq('ek')
  end

  it 'has persisted the expected mail' do
    expect(edna.email).to be_nil
  end

  it 'has persisted the expected subjects' do
    expect(edna.fächer).to_not be_empty
    expect(edna.fächer.size).to eq(3)
    expect(edna.fächer[0].name).to eq('Englisch')
    expect(edna.fächer[1].name).to eq('Geografie')
    expect(edna.fächer[2].name).to eq('Naturwissenschaft und Technik')
  end
end
