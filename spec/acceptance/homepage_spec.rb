# frozen_string_literal: true

require_relative 'helper'

describe 'Homepage', type: :feature do
  it 'has some basic stats' do
    visit '/'

    within('.content') do
      expect(page).to have_content 'Statistik'
      expect(page).to have_content '0 Eltern'
    end
  end
end
