# frozen_string_literal: true

describe Erziehungsberechtigter do
  context 'with existing parents' do
    before do
      described_class.create(vorname: 'Homer', nachname: 'Simpson', mail: 'homer@simpson.org')
      described_class.create(vorname: 'Marge', nachname: 'Simpson', mail: 'marge@simpson.org')
      described_class.create(vorname: 'Luann', nachname: 'Van Houten', mail: 'luann@vanhouten.org')
      described_class.create(vorname: 'Kirk', nachname: 'Van Houten', mail: 'kirk@vanhouten.org')
      described_class.create(vorname: 'Eddie', nachname: 'Muntz', mail: 'eddie@muntz.org')
      described_class.create(nachname: 'Muntz')
    end

    it 'provides a mailing list for all parents' do
      expect(described_class.all.mailing_list).to be
      expect(described_class.all.mailing_list.name).to eq('Alle Eltern')
      expect(described_class.all.mailing_list.address).to eq('eltern')
      expect(described_class.all.mailing_list.url).to eq('/verteiler/eltern')
      expect(described_class.all.mailing_list.members).to be
      expect(described_class.all.mailing_list.members).to_not be_empty
      expect(described_class.all.mailing_list.members.count).to eq(6)
    end
  end

  context 'an ordinary parent' do
    subject(:homer) { described_class.new }

    it 'persists' do
      homer.nachname = 'Simpson'
      homer.save
      homer.refresh
      expect(homer.nachname).to eq('Simpson')
      expect(homer.name).to eq('Simpson')
    end

    it 'may have a first name' do
      homer.nachname = 'Simpson'
      homer.vorname = 'Homer'
      homer.save
      expect(homer.vorname).to eq('Homer')
      expect(homer.name).to eq('Simpson, Homer')
    end

    it 'may have an empty first name' do
      homer.vorname = ''
      homer.mail = 'Homer'
      homer.save
    end

    it 'may have a mail address' do
      homer.mail = 'Homer'
      homer.save
      expect(homer.mail).to eq('Homer')
    end

    it 'may have an empty mail if lastname is present' do
      homer.nachname = 'Simpson'
      homer.mail = ''
      homer.save
    end

    it 'may have a phone number' do
      homer.nachname = 'Simpson'
      homer.telefon = 'Homer'
      homer.save
      expect(homer.telefon).to eq('Homer')
    end

    it 'must have at least a last name' do
      expect { homer.save }.to raise_error(Erziehungsberechtigter::ValidationError)
    end

    it 'can have an empty phone number if lastname is present' do
      homer.nachname = 'Simpson'
      homer.telefon = ''
      homer.save
    end

    it 'has a forme namespace' do
      expect(homer.forme_namespace).to eq('sgh-elternverteiler-erziehungsberechtigter')
    end

    context 'without an email address' do
      before do
        homer.nachname = 'Simpson'
        homer.vorname = 'Homer'
      end

      it 'has a string representation' do
        expect(homer.to_s).to eq('Homer Simpson')
      end
    end

    context 'with just an email address' do
      before do
        homer.mail = 'homer@thesimpsons.org'
        homer.save
      end

      it 'has a string representation' do
        expect(homer.to_s).to eq('homer@thesimpsons.org')
      end
    end

    context 'with first and last name and an email address' do
      before do
        homer.vorname = 'Homer'
        homer.nachname = 'Simpson'
        homer.mail = 'homer@thesimpsons.org'
        homer.save
      end

      it 'has a string representation' do
        expect(homer.to_s).to eq('Homer Simpson <homer@thesimpsons.org>')
      end
    end

    it 'has no roles' do
      expect(homer.rollen).to be_empty
    end

    it 'has no Ämter' do
      expect(homer.ämter).to be_empty
    end
  end
end
