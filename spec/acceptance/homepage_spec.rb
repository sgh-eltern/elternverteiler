# frozen_string_literal: true

require_relative 'helper'

describe 'Homepage', type: :feature do
  it 'has stats for an empty database' do
    visit '/'

    within('.content') do
      expect(page).to have_content('Statistik')
      expect(page).to have_content('0 Eltern')
      expect(page).to have_content('0 Schüler')
      # expect(page).to have_content('0 (0%) nicht per Mail erreichbar')
    end
  end
end
