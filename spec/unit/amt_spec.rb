# frozen_string_literal: true

describe Amt do
  subject(:pab) { described_class.new(name: 'Member of the Parent Advisory Board').save }
  let(:klasse) { Klasse.new(stufe: '4', zug: 'a').save }

  it 'has a name' do
    expect(pab.name).to eq('Member of the Parent Advisory Board')
  end

  it 'has an empty set of members' do
    expect(pab.mitglieder).to be_empty
  end

  it 'cannot create another role with the same name' do
    expect { described_class.new(name: subject.name).save }.to raise_error(Sequel::UniqueConstraintViolation)
  end

  context 'some parents are members' do
    let(:homer) { Erziehungsberechtigter.new(vorname: 'Homer', nachname: 'Simpson').save }
    let(:chief_wiggum) { Erziehungsberechtigter.new(vorname: 'Clancy', nachname: 'Wiggum').save }
    let(:marge) { Erziehungsberechtigter.new(vorname: 'Marge', nachname: 'Simpson').save }

    before do
      Amtsperiode.new(
        inhaber: homer,
        amt: pab,
        klasse: klasse
        ).save

      Amtsperiode.new(
        inhaber: chief_wiggum,
        amt: pab,
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
