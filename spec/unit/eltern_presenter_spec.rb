# frozen_string_literal: true

require 'spec_helper'
require 'sgh/elternverteiler/eltern_presenter'

describe ElternPresenter do
  subject { described_class.new('eltern@springfield-elementary.edu') }

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
  end
end
