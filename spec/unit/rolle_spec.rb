# frozen_string_literal: true

require 'spec_helper'

describe Rolle do
  subject(:pab) { Rolle.new(name: 'Member of the Parent Advisory Board').save }
  let(:klasse) { Klasse.new(stufe: '4', zug: 'a').save }

  it 'has a name' do
    expect(pab.name).to eq('Member of the Parent Advisory Board')
  end

  it 'has an empty set of members' do
    expect(pab.mitglieder).to be_empty
  end

  context 'some parents are members' do
    let(:homer) { Erziehungsberechtigter.new(vorname: 'Homer', nachname: 'Simpson').save }
    let(:chief_wiggum) { Erziehungsberechtigter.new(vorname: 'Clancy', nachname: 'Wiggum').save }
    let(:marge) { Erziehungsberechtigter.new(vorname: 'Marge', nachname: 'Simpson').save }

    before do
      Amt.new(
        erziehungsberechtigter: homer,
        rolle: pab,
        klasse: klasse
        ).save

      Amt.new(
        erziehungsberechtigter: chief_wiggum,
        rolle: pab,
        klasse: klasse
        ).save
      # Marge is not in the PAB
    end

    it 'has a non-empty list of members' do
      expect(pab.mitglieder).to_not be_empty
    end

    it 'has the expected members' do
      expect(pab.mitglieder.count).to eq(2)
    end

    it 'becomes an attribute of the parents' do
      expect(homer.rollen).to include(pab)
      expect(chief_wiggum.rollen).to include(pab)
    end

    it 'does not become an attribute of parents who are not members' do
      expect(marge.rollen).to_not include(pab)
    end

    it 'has a string representation' do
      expect(pab.to_s).to eq('Member of the Parent Advisory Board')
    end
  end
end
