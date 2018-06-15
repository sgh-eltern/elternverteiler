# frozen_string_literal: true

require_relative 'helper'

describe 'Klassen', type: :feature do
  context '5K exists' do
    before do
      create_class('5', 'K')
      visit '/'
      within('#menu') { click_link('Klassen') }
      within('.content') { click_link('5K') }
    end

    after { delete_class!('5K') }

    it 'lists Elternvertreter' do
      expect(page).to have_content 'Elternvertreter'
    end

    it 'has a generic address to reach the Elternvertreter of this class' do
      expect(page).to have_content 'eMail: elternvertreter-5k@schickhardt-gymnasium-herrenberg.de'
    end

    context 'attempting to create another role with the same name' do
      before do
        create_class('5', 'K')
      end

      it 'provides details on the error' do
        within('aside.error') do
          expect(page).to have_content('Die Klasse 5K existiert bereits')
        end
      end
    end

    context 'J1 exists' do
      before do
        create_class('J', '1')
        visit '/'
        within('#menu') { click_link('Klassen') }
      end

      after { delete_class!('J1') }

      it 'lists both 5K and J1' do
        within('.content') do
          expect(page).to have_content '5K'
          expect(page).to have_content 'J1'
        end
      end

      context '5K is deleted' do
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
