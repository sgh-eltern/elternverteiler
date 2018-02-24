# frozen_string_literal: true

require_relative 'helper'

describe 'Klassen', type: :feature do
  before(:all) {
    create_class('5', 'A')
    create_class('J', '1')
  }

  it 'lists all Klassen' do
    visit '/'

    within('#menu') do
      click_link('Klassen')
    end

    within('.content') do
      expect(page).to have_content '5A'
      expect(page).to have_content 'J1'
    end
  end
end
