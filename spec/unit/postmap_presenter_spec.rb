# frozen_string_literal: true

require 'sgh/elternverteiler/postmap_presenter'

describe PostmapPresenter do
  subject { described_class.new(mail).present(exhibit) }

  context 'all parents' do
    let(:mail) { 'eltern@springfield-elementary.edu' }
    let(:exhibit) { Erziehungsberechtigter.all }

    context 'without any parents' do
      it 'returns an empty string' do
        expect(subject.to_s).to eq('')
      end
    end

    context 'with some parents in 4th grade' do
      before do
        Erziehungsberechtigter.new(vorname: 'Homer', nachname: 'Simpson', mail: 'homer@simpson.org').save
        Erziehungsberechtigter.new(vorname: 'Marge', nachname: 'Simpson', mail: 'marge@simpson.org').save
        Erziehungsberechtigter.new(vorname: 'Luann', nachname: 'Van Houten', mail: 'luann@vanhouten.org').save
        Erziehungsberechtigter.new(vorname: 'Kirk', nachname: 'Van Houten', mail: 'kirk@vanhouten.org').save
        Erziehungsberechtigter.new(vorname: 'Eddie', nachname: 'Muntz', mail: 'eddie@muntz.org').save
        Erziehungsberechtigter.new(nachname: 'Muntz').save
      end

      it 'starts with the distribution list address' do
        expect(subject.to_s).to start_with('eltern@springfield-elementary.edu')
      end

      it 'contains the addresses of all parents' do
        expect(subject.to_s).to include('homer@simpson.org')
        expect(subject.to_s).to include('marge@simpson.org')
        expect(subject.to_s).to include('luann@vanhouten.org')
        expect(subject.to_s).to include('kirk@vanhouten.org')
        expect(subject.to_s).to include('eddie@muntz.org')
      end

      context 'some parents sharing a single mail address' do
        before do
          Erziehungsberechtigter.new(vorname: 'Ned', nachname: 'Flanders', mail: 'flanders@firstchurch.org').save
          Erziehungsberechtigter.new(vorname: 'Maude', nachname: 'Flanders', mail: 'flanders@firstchurch.org').save
        end

        it 'contains the addresses of Ned and Maude parents' do
          expect(subject.to_s).to include('flanders@firstchurch.org')
        end

        it 'has no dupes' do
          addresses = subject.to_s.split(' ').last.split(',')
          expect(addresses.size).to eq(addresses.uniq.size)
        end
      end

      it 'does not contain empty fields' do
        expect(subject.to_s).to_not end_with(',')
        expect(subject.to_s).to_not include(',,')
      end
    end
  end
end
