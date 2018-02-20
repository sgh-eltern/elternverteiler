# frozen_string_literal: true

require_relative 'helper'

describe 'Homepage', type: :feature do
  it 'has some basic stats' do
    visit '/'

    within('.content') do
      expect(page).to have_content('Statistik')
      expect(page).to have_content(/\d+ Eltern/)
    end
  end
end
