# frozen_string_literal: true

require_relative 'helper'

describe 'Verteiler', type: :feature do
  before do
    visit '/'
    within('#menu') { click_link('Verteiler') }
  end

  it 'has a page title' do
    expect(page).to have_content('eMail-Verteiler')
  end

  it 'has Klassen' do
    within('.content') do
      expect(page).to have_content('# Klassen')
    end
  end

  it 'has Klassenstufen' do
    within('.content') do
      expect(page).to have_content('# Klassenstufen')
    end
  end

  it 'has all Eltern' do
    within('.content') do
      expect(page).to have_content('# Alle Eltern')
    end
  end

  it 'has the Elternbeirat' do
    within('.content') do
      expect(page).to have_content('# Elternbeirat')
    end
  end

  it 'has the Elternvertreter in der Schulkonferenz' do
    within('.content') do
      expect(page).to have_content('# Elternvertreter in der Schulkonferenz')
    end
  end

  it 'has the Elternbeiratsvorsitzende' do
    within('.content') do
      expect(page).to have_content('# Elternbeiratsvorsitzende')
    end
  end
end
