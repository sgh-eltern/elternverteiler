# frozen_string_literal: true

require_relative 'helper'

describe 'Klassen', type: :feature do
  it 'lists all Klassen' do
    visit '/'

    within('#menu') do
      click_link('Klassen')
    end

    expect(page).to have_content '5A'
    expect(page).to have_content 'J1'
  end
end
