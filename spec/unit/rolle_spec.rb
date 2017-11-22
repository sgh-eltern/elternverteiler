# frozen_string_literal: true

require 'spec_helper'

describe Rolle do
  subject(:pab) { Rolle.new(name: 'parent advisory board').save }

  it 'has a name' do
    expect(pab.name).to eq('parent advisory board')
  end

  it 'has an empty set of members' do
    expect(pab.mitglieder).to be_empty
  end

  context 'some parents are members' do
    let(:homer) { Erziehungsberechtigter.new(vorname: 'Homer', nachname: 'Simpson').save }
    let(:chief_wiggum) { Erziehungsberechtigter.new(vorname: 'Clancy', nachname: 'Wiggum').save }
    let(:marge) { Erziehungsberechtigter.new(vorname: 'Marge', nachname: 'Simpson').save }

    before do
      pab.add_mitglieder(homer)
      pab.add_mitglieder(chief_wiggum)
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
      expect(pab.to_s).to eq('parent advisory board')
    end

    context 'some parents are members of multiple boards' do
      let(:cash_auditors) { Rolle.new(name: 'cash auditors').save }

      before do
        cash_auditors.add_mitglieder(chief_wiggum)
      end

      it 'adds all roles as an attribute of the member' do
        expect(chief_wiggum.rollen).to include(pab).and include(cash_auditors)
      end

      it 'does not become an attribute of parents who are not members of additional boards' do
        expect(homer.rollen).to_not include(cash_auditors)
      end
    end
  end
end
