# frozen_string_literal: true

require_relative 'helper'

describe 'Rollen', type: :feature do
  before do
    visit '/'

    within('#menu') do
      click_link('Rollen')
    end
  end

  it 'has a page title' do
    expect(page).to have_content 'Rollen'
  end

  context 'a role exists' do
    before(:all) do
      create_role('Klassenkasper')
    end

    it 'lists all roles' do
      within('.content') do
        expect(page).to have_content 'Klassenkasper'
      end
    end
  end
end
