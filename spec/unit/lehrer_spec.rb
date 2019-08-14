# frozen_string_literal: true

require 'spec_helper'

describe Lehrer do
  subject(:edna) { Lehrer.new(vorname: 'Edna', nachname: 'Krabappel') }
  let(:skinner) { Lehrer.new(vorname: 'Seymour', nachname: 'Skinner') }

  it 'has a forme namespace' do
    expect(subject.forme_namespace).to eq('sgh-elternverteiler-lehrer')
  end

  it 'can be compared' do
    expect(edna).to eq(edna)
    expect(edna).to eq(Lehrer.new(vorname: 'Edna', nachname: 'Krabappel'))
    expect(edna).not_to eq(skinner)
  end

  it 'can be sorted' do
    expect([skinner, edna].sort).to eq([edna, skinner])
  end
end
