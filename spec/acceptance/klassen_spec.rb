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

    after { delete_class('5K') }

    it 'lists Elternvertreter' do
      expect(page).to have_content 'Elternvertreter'
    end

    it 'has a generic address to reach the Elternvertreter of this class' do
      expect(page).to have_content 'eMail: elternvertreter-5k@schickhardt-gymnasium-herrenberg.de'
    end

    it 'it refuses to create another role with the same name' do
      create_class('5', 'K')
      within('aside.error') do
        expect(page).to have_content('Die Klasse 5K existiert bereits')
      end
    end

    context 'Bart is a pupil in 5K' do
      before do
        create_pupil('Simpson', 'Bart', '5K')
        create_parent('Simpson', 'Homer', 'homer@simpson.name')
        assign_parent('Simpson', 'Simpson, Homer')
      end

      after do
        delete_parent('Simpson', 'Homer', 'homer@simpson.name')
        delete_pupil('Simpson', 'Bart', '5K')
        delete_class('5K')
      end

      it 'refuses to remove the Klasse while it still has pupils' do
        delete_class('5K')
        within('aside.error') do
          expect(page).to have_content('Die Klasse 5K hat Schüler und kann deshalb nicht gelöscht werden.')
        end
      end
    end

    context 'J1 exists' do
      before { create_class('J', '1') }
      after { delete_class('J1') }

      it 'lists both 5K and J1' do
        within('#menu') { click_link('Klassen') }
        within('.content') do
          expect(page).to have_content '5K'
          expect(page).to have_content 'J1'
        end
      end

      context '5K is deleted' do
        before { delete_class('5K') }

        it 'still lists J1' do
          within('#menu') { click_link('Klassen') }
          within('.sgh-elternverteiler-klassen') do
            expect(page).to_not have_content('5K')
            expect(page).to have_content 'J1'
          end
        end
      end
    end
  end
end
