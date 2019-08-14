# frozen_string_literal: true

require_relative 'spec_helper'

require 'pathname'
require 'sgh/elternverteiler/reachability_mail_generator'

describe ReachabilityMailGenerator, type: 'system' do
  let(:klassenstufe_4) { Klassenstufe.create(name: '4') }
  let(:k4a) { Klasse.create(stufe: klassenstufe_4, zug: 'a') }
  let(:view_path) { Pathname(__dir__) / '..' / '..' / 'views/mail/missing.markdown.erb' }

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

  it 'yields to the block for every Klasse' do
    expect { |block| described_class.new(view_path, &block) }.to yield_control.exactly(25).times
  end
end
