# frozen_string_literal: true

describe Amt do
  subject(:pab) { Amt.new(name: 'Member of the Parent Advisory Board').save }
  let(:klassenstufe_4) { Klassenstufe.new(name: '4').save }
  let(:klasse) { Klasse.new(stufe: klassenstufe_4, zug: 'a').save }

  it 'has a name' do
    expect(pab.name).to eq('Member of the Parent Advisory Board')
  end

  it 'has an empty set of members' do
    expect(pab.amtsperioden).to be_empty
  end

  it 'cannot create another Amt with the same name' do
    expect { Amt.new(name: subject.name).save }.to raise_error(Sequel::UniqueConstraintViolation)
  end

  context 'some parents are members' do
    let(:homer) { Erziehungsberechtigter.new(vorname: 'Homer', nachname: 'Simpson').save }
    let(:chief_wiggum) { Erziehungsberechtigter.new(vorname: 'Clancy', nachname: 'Wiggum').save }
    let(:marge) { Erziehungsberechtigter.new(vorname: 'Marge', nachname: 'Simpson').save }

    before do
      Amtsperiode.create(
        inhaber: homer,
        amt: pab,
        klasse: klasse
        )

      Amtsperiode.create(
        inhaber: chief_wiggum,
        amt: pab,
        klasse: klasse
        )
      # Marge is not in the PAB
    end

    it 'has a non-empty list of members' do
      expect(pab.amtsperioden).to_not be_empty
    end

    it 'has the expected members' do
      expect(pab.amtsperioden.count).to eq(2)
    end

    it 'becomes an attribute of the parents' do
      expect(homer.ämter).to include(pab)
      expect(chief_wiggum.ämter).to include(pab)
    end

    it 'does not become an attribute of parents who are not members' do
      expect(marge.ämter).to_not include(pab)
    end

    it 'has a string representation' do
      expect(pab.to_s).to eq('Member of the Parent Advisory Board')
    end
  end
end
