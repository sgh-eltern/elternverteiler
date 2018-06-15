# frozen_string_literal: true

require_relative 'helper'

describe 'Verteiler', type: :feature do
  before(:all) do
    create_class('5', 'V')
    create_pupil('Simpson', 'Bart', '5V')
    create_parent('Simpson', 'Homer', 'homer@simpson.name')
    assign_parent('Simpson', 'Simpson, Homer')
  end

  after(:all) do
    delete_parent('Simpson', 'Homer', 'homer@simpson.name')
    delete_pupil('Simpson', 'Bart', '5V')
    delete_class('5V')
  end

  before do
    visit '/'
    within('#menu') { click_link('Verteiler') }
  end

  it 'has Klassen' do
    expect(page).to have_content('# Klassen')
    expect(page).to have_content('# Klasse 5V')
    expect(page).to have_content('eltern-5v@schickhardt-gymnasium-herrenberg.de homer@simpson.name')
  end

  it 'has Klassenstufen' do
    expect(page).to have_content('# Klassenstufen')
    expect(page).to have_content('# Klasse 5')
    expect(page).to have_content('eltern-5@schickhardt-gymnasium-herrenberg.de homer@simpson.name')
  end

  it 'has all Eltern' do
    expect(page).to have_content('# Alle Eltern')
    expect(page).to have_content('eltern@schickhardt-gymnasium-herrenberg.de homer@simpson.name')
  end

  it 'has the Elternbeirat' do
    expect(page).to have_content('# Elternbeirat')
  end

  it 'has the Elternvertreter in der Schulkonferenz' do
    expect(page).to have_content('# Elternvertreter in der Schulkonferenz')
  end

  it 'has the Elternbeiratsvorsitzende' do
    expect(page).to have_content('# Elternbeiratsvorsitzende')
  end

  context 'Homer is the primary Elternvertreter of 5V' do
    before(:all) do
      create_role('1.EV')
      assign_role('5V', 'Simpson, Homer', '1.EV')
      within('#menu') { click_link('Verteiler') }
    end

    it 'has the address of the Elternvertreter of 5V' do
      expect(page).to have_content('elternvertreter-5v@schickhardt-gymnasium-herrenberg.de homer@simpson.name')
    end

    it 'has the address of the Elternvertreter of 5' do
      expect(page).to have_content('elternvertreter-5@schickhardt-gymnasium-herrenberg.de homer@simpson.name')
    end
  end
end
