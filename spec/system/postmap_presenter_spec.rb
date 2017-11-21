# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'
require 'sgh/elternverteiler/postmap_presenter'

describe PostmapPresenter, type: 'system' do
  let(:k4a) { Klasse.new(stufe: '4', zug: 'a').save }

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

  before do
    File.write(@db_file.path, described_class.new('eltern@springfield-elementary.edu').present(Erziehungsberechtigter.all))
  end

  it 'contains a sizable amount of characters' do
    expect(@db_file.size).to be > 100
  end

  it 'is parsable by postmap without errors' do
    expect { `postmap hash:#{@db_file.path}` }.to_not output.to_stderr
  end
end
