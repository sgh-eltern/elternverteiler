# frozen_string_literal: true

require 'spec_helper'

require 'sgh/elternverteiler/fach_mapper'

describe FachMapper do
  subject(:mapper) { described_class.new }
  let(:kürzel) { %w[E Geo NwT] }

  context 'mapping multiple abbreviations' do
    let(:fächer) { mapper.map(*kürzel) }

    it 'produces some subjects' do
      expect(fächer).to_not be_empty
    end

    it 'produces all subjects' do
      expect(fächer.size).to eq(3)
      expect(fächer).to all(be)
    end

    it 'produces the correct names' do
      expect(fächer[0].name).to eq('Englisch')
      expect(fächer[1].name).to eq('Geografie')
      expect(fächer[2].name).to eq('Naturwissenschaft und Technik')
    end
  end
end
