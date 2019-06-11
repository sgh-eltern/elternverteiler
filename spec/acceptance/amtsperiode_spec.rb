# frozen_string_literal: true

require_relative 'helper'

describe 'Amtsperiode', type: :feature do
  before(:all) do
    create_klassenstufe('5')
    create_class('5', 'A')
  end

  after(:all) do
    delete_class('5A')
    delete_klassenstufe('5')
  end

  before do
    create_pupil('Simpson', 'Bart', '5A')
    create_parent('Simpson', 'Homer', 'homer@simpson.name')
    assign_parent('Simpson', 'Simpson, Homer')
  end

  after do
    delete_parent('Simpson', 'Homer', 'homer@simpson.name')
    delete_pupil('Simpson', 'Bart', '5A')
  end

  context 'no roles assigned' do
    before do
      visit '/'
      within('#menu') { click_link('Klassen') }
      within('.content') { click_link('5A') }
    end

    it 'lists no roles' do
      within('.sgh-elternverteiler-amtsinhaber') do
        expect(page).to_not have_css('td')
      end
    end
  end

  context 'Homer is the designated clown of 5A' do
    before do
      create_role('Elternvertreter', 'ev1')
      assign_role('5A', 'Simpson, Homer', 'Elternvertreter')
    end

    after do
      delete_role('Elternvertreter')
    end

    fit 'lists Homer in his role in the class' do
      visit '/'
      within('#menu') { click_link('Klassen') }
      within('.content') { click_link('5A') }

      within('.sgh-elternverteiler-amtsinhaber') do
        expect(page).to have_content('Elternvertreter')
      end
    end
  end
end
