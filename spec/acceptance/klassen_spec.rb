# frozen_string_literal: true

require_relative 'helper'

describe 'Klassen', type: :feature do
  context '5K exists' do
    before(:all) do
      create_class('5', 'K')
    end

    after(:all) do
      delete_class!('5K')
    end

    before do
      visit '/'
      within('#menu') { click_link('Klassen') }
      within('.content') { click_link('5K') }
    end

    it 'Lists Elternvertreter' do
      expect(page).to have_content 'Elternvertreter'
    end

    it 'has a generic address to reach the Elternvertreter of this class' do
      expect(page).to have_content 'eMail: elternvertreter-5k@schickhardt-gymnasium-herrenberg.de'
    end

    context 'J1 exists' do
      before(:all) do
        create_class('J', '1')
      end

      after(:all) do
        delete_class!('J1')
      end

      before do
        visit '/'
        within('#menu') { click_link('Klassen') }
      end

      it 'lists both 5K and J1' do
        within('.content') do
          expect(page).to have_content '5K'
          expect(page).to have_content 'J1'
        end
      end

      context '5K is deleted' do
        before do
          visit '/'
          within('#menu') { click_link('Klassen') }
        end

        it '5K is not listed anymore, but J1 still is' do
          delete_class!('5K')
          within('.sgh-elternverteiler-klassen') do
            expect(page).to_not have_content('5K')
            expect(page).to have_content 'J1'
          end
        end
      end
    end
  end
end
