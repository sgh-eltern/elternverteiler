# frozen_string_literal: true

require_relative 'spec_helper'

require 'sequel'
require 'que'
require 'pathname'
require 'sgh/elternverteiler/reachability_presenter'

describe 'Mail is handled asynchronously', type: 'system' do
  let(:klassenstufe_4) { Klassenstufe.create(name: '4') }
  let(:k4a) { Klasse.create(stufe: klassenstufe_4, zug: 'a') }
  let(:view_path) {Pathname(__dir__) / '..' / '..' / 'views/mail/missing.markdown.erb'}

  before do
    Que.connection = Sequel::Model.db
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

  subject(:presenter) { ReachabilityPresenter.new(view_path) }

  it 'accepts a new mailer job' do
    expect(presenter.jobs).not_to be_empty
    expect(presenter.jobs.size).to eq(25)
  end

  it 'has stats' do
    expect(Que.job_stats).not_to be_nil
  end
end
