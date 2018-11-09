# frozen_string_literal: true
require 'spec_helper'

describe 'Lehrer <=> Fächer' do
  it 'Lehrer haben Fächer'
  it 'Fächer haben Lehrer'

  context 'no Lehrer teaches the Fach anymore' do
    it 'keeps the Fach itself'
    it 'the Fach has no Lehrer anymore'
  end

  context 'a Lehrer leaves the school' do
    it 'no longer shows the Lehrer as teaching the Fach'
  end
end
