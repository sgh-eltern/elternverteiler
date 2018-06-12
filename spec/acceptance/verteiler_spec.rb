# frozen_string_literal: true

require_relative 'helper'

describe 'Verteiler', type: :feature do
  before(:all) do
    @simpson = "Simpson-#{rand(1000)}"
    @bart = "Bart-#{rand(1000)}"
    @homer = "Homer-#{rand(1000)}"

    create_class('5', 'C')
    create_pupil(@simpson, @bart, '5C')
    create_parent(@simpson, @homer, 'homer@simpson.name')
    assign_parent(@simpson, "#{@simpson}, #{@homer}")
  end

  before do
    visit '/'
    within('#menu') { click_link('Verteiler') }
  end

  it 'has Klassen' do
    expect(page).to have_content('# Klassen')
    expect(page).to have_content('# 5C')
    expect(page).to have_content('eltern-5c@schickhardt-gymnasium-herrenberg.de homer@simpson.name')
  end

  it 'has Klassenstufen' do
    expect(page).to have_content('# Klassenstufen')
    expect(page).to have_content('# 5')
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
end
