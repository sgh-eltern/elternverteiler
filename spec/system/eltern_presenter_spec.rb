# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'
require 'sgh/elternverteiler/eltern_presenter'

describe ElternPresenter, type: 'system' do
  before do
    Schüler.new(vorname: 'Bart', nachname: 'Simpson', klasse: '4a').save
    Erziehungsberechtigter.new(vorname: 'Homer', nachname: 'Simpson', mail: 'homer@simpson.org').save
    Erziehungsberechtigter.new(vorname: 'Marge', nachname: 'Simpson', mail: 'marge@simpson.org').save
    Schüler.new(vorname: 'Milhouse', nachname: 'Van Houten', klasse: '4a').save
    Erziehungsberechtigter.new(vorname: 'Luann', nachname: 'Van Houten', mail: 'luann@vanhouten.org').save
    Erziehungsberechtigter.new(vorname: 'Kirk', nachname: 'Van Houten', mail: 'kirk@vanhouten.org').save
    Schüler.new(vorname: 'Nelson', nachname: 'Muntz', klasse: '4a').save
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
    File.write(@db_file.path, described_class.new('eltern@springfield-elementary.edu').to_s)
  end

  it 'is parsable by postmap without errors' do
    expect { `postmap hash:#{@db_file.path}` }.to_not output.to_stderr
  end
end
