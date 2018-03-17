# frozen_string_literal: true

require 'tempfile'
require 'sgh/elternverteiler/postmap_presenter'

describe 'A file with all parents presented with PostmapPresenter', type: 'system' do
  let(:k4a) { Klasse.new(stufe: '4', zug: 'a').save }
  subject {
    File.write(@db_file.path, PostmapPresenter.new('eltern@springfield-elementary.edu').present(Erziehungsberechtigter.all))
    @db_file
  }

  before do
    Schüler.new(vorname: 'Bart', nachname: 'Simpson', klasse: k4a).save
    Erziehungsberechtigter.new(vorname: 'Homer', nachname: 'Simpson', mail: 'homer@simpson.org').save
    Erziehungsberechtigter.new(vorname: 'Marge', nachname: 'Simpson', mail: 'marge@simpson.org').save
    Schüler.new(vorname: 'Milhouse', nachname: 'Van Houten', klasse: k4a).save
    Erziehungsberechtigter.new(vorname: 'Luann', nachname: 'Van Houten', mail: 'luann@vanhouten.org').save
    Erziehungsberechtigter.new(vorname: 'Kirk', nachname: 'Van Houten', mail: 'kirk@vanhouten.org').save
    Schüler.new(vorname: 'Nelson', nachname: 'Muntz', klasse: k4a).save
    Erziehungsberechtigter.new(vorname: 'Eddie', nachname: 'Muntz', mail: 'eddie@muntz.org').save
    Erziehungsberechtigter.new(nachname: 'Muntz').save
  end

  around do |example|
    Tempfile.create('eltern-presenter') do |tmp_file|
      @db_file = tmp_file
      example.run
      @db_file = nil
    end
  end

  it 'contains a sizable amount of characters' do
    expect(subject.size).to be > 100
  end

  it 'is parsable by postmap without errors' do
    expect { %x(postmap hash:#{subject.path}) }.to_not output.to_stderr
  end
end
