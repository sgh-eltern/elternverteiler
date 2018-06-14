# frozen_string_literal: true

require_relative 'helper'

describe 'Ämter', type: :feature do
  let(:simpson) { "Simpson-#{rand(1000)}" }
  let(:homer) { "Homer-#{rand(1000)}" }
  let(:simpson_homer) { "#{simpson}, #{homer}" }
  let(:bart) { "Bart-#{rand(1000)}" }

  before(:all) do
    create_class('5', 'A')
  end

  after(:all) do
    delete_class!('5A')
  end

  before do
    create_pupil(simpson, bart, '5A')
    create_parent(simpson, homer, 'homer@simpson.name')
    assign_parent(simpson, simpson_homer)
  end

  context 'no roles assigned' do
    before do
      visit '/'
      within('#menu') { click_link('Klassen') }
      within('.content') { click_link('5A') }
    end

    it 'lists no roles' do
      within('.sgh-elternverteiler-erziehungsberechtigter') do
        expect(page).to_not have_css('td')
      end
    end
  end

  context 'Homer is the designated clown of 5A' do
    before do
      create_role('1.EV')
      assign_role('5A', simpson_homer, '1.EV')
    end

    after do
      delete_role('1.EV')
    end

    it 'lists Homer in his role in the class' do
      visit '/'
      within('#menu') { click_link('Klassen') }
      within('.content') { click_link('5A') }

      within('.sgh-elternverteiler-erziehungsberechtigter') do
        expect(page).to have_content('1.EV')
      end
    end
  end
end
