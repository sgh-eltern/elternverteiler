# frozen_string_literal: true

require_relative 'spec_helper'

require 'sequel'
require 'tempfile'
require 'sgh/elternverteiler/postmap_presenter'

describe 'A file with all parents presented with PostmapPresenter', type: 'system' do
  let(:klassenstufe_4) { Klassenstufe.create(name: '4') }
  let(:k4a) { Klasse.create(stufe: klassenstufe_4, zug: 'a') }

  subject {
    File.write(@db_file.path, PostmapPresenter.new('eltern@springfield-elementary.edu').present(Erziehungsberechtigter.all))
    @db_file
  }

  before do
    Sequel.extension :migration
    Sequel::Migrator.run(Sequel::Model.db, 'db/migrations')
    require 'sgh/elternverteiler'

    Schüler.create(vorname: 'Bart', nachname: 'Simpson', klasse: k4a)
    Erziehungsberechtigter.create(vorname: 'Homer', nachname: 'Simpson', mail: 'homer@simpson.org')
    Erziehungsberechtigter.create(vorname: 'Marge', nachname: 'Simpson', mail: 'marge@simpson.org')
    Schüler.create(vorname: 'Milhouse', nachname: 'Van Houten', klasse: k4a)
    Erziehungsberechtigter.create(vorname: 'Luann', nachname: 'Van Houten', mail: 'luann@vanhouten.org')
    Erziehungsberechtigter.create(vorname: 'Kirk', nachname: 'Van Houten', mail: 'kirk@vanhouten.org')
    Schüler.create(vorname: 'Nelson', nachname: 'Muntz', klasse: k4a)
    Erziehungsberechtigter.create(vorname: 'Eddie', nachname: 'Muntz', mail: 'eddie@muntz.org')
    Erziehungsberechtigter.create(nachname: 'Muntz')
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
