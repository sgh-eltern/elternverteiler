# frozen_string_literal: true

require_relative 'helpers/postgres'
require 'sequel'
require 'sgh/elternverteiler/reachability_presenter'

describe 'Mail is handled asynchronously', type: 'system' do
  def example_id
    @example_id ||= "async-mail-systemtest-#{Time.now.to_i}"
  end

  let(:db_url) { "postgres://localhost/#{example_id}" }
  let(:klassenstufe_4) { Klassenstufe.new(name: '4').save }
  let(:k4a) { Klasse.new(stufe: klassenstufe_4, zug: 'a').save }
  let(:view_path) {Pathname(__dir__) / '..' / '..' / 'views/mail/missing.markdown.erb'}

  before(:all) do
    PostgresHelpers.create_db(example_id)
  end

  before do
    Sequel::Model.db = Sequel.connect(db_url)
    Sequel.extension :migration
    Sequel::Migrator.run(Sequel::Model.db, 'db/migrations')
  end

  after do
    Sequel::Model.db.disconnect
  end

  after(:all) do
    PostgresHelpers.drop_db(example_id)
  end

  around do |example|
    Sequel::Model.db.transaction(rollback: :always, auto_savepoint: true) { example.run }
  end

  before do
    bart = Schüler.create(vorname: 'Bart', nachname: 'Simpson', klasse: k4a)
    homer = Erziehungsberechtigter.create(vorname: 'Homer', nachname: 'Simpson', mail: 'homer@simpson.org')
    marge = Erziehungsberechtigter.create(vorname: 'Marge', nachname: 'Simpson', mail: 'marge@simpson.org')
    bart.add_eltern(marge)
    bart.add_eltern(homer)

    milhouse = Schüler.create(vorname: 'Milhouse', nachname: 'Van Houten', klasse: k4a)
    luann = Erziehungsberechtigter.create(vorname: 'Luann', nachname: 'Van Houten', mail: 'luann@vanhouten.org')
    kirk = Erziehungsberechtigter.create(vorname: 'Kirk', nachname: 'Van Houten')
    milhouse.add_eltern(luann)
    milhouse.add_eltern(kirk)

    nelson = Schüler.create(vorname: 'Nelson', nachname: 'Muntz', klasse: k4a)
    eddie = Erziehungsberechtigter.create(vorname: 'Eddie', nachname: 'Muntz')
    nelson.add_eltern(eddie)
  end

  subject(:presenter) { SGH::Elternverteiler::ReachabilityPresenter.new(view_path) }

  it 'accepts a new mailer job' do
    expect(presenter.jobs).not_to be_empty
    expect(presenter.jobs.size).to eq(1)
  end
end
