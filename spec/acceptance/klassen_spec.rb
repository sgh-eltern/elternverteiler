# frozen_string_literal: true

require_relative 'helper'

describe 'Klassen', type: :feature do
  context '5K exists' do
    before do
      create_klassenstufe('5')
      create_class('5', 'K')
      visit '/'
      within('#menu') { click_link('Klassen') }
      within('.content') { click_link('5K') }
    end

    after do
      delete_class('5K')
      delete_klassenstufe('5')
    end

    it 'has a title' do
      expect(page).to have_title('Klasse 5K - Elternbeirat am SGH')
    end

    describe 'Elternvertreter' do
      it 'lists them' do
        within('section.sgh-elternverteiler-elternvertreter') do
          expect(page).to have_content 'Elternvertreter'
        end
      end

      it 'has a generic address to reach them' do
        within('section.sgh-elternverteiler-elternvertreter') do
          expect(page).to have_content 'eMail: elternvertreter-5k@schickhardt-gymnasium-herrenberg.de'
        end
      end
    end

    describe 'Eltern' do
      it 'lists them' do
        expect(page).to have_content 'Eltern'
      end

      it 'has a generic address to reach them' do
        expect(page).to have_content 'eMail: eltern-5k@schickhardt-gymnasium-herrenberg.de'
      end
    end

    it 'it refuses to create another Klasse with the same name' do
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

      context '5K is deleted' do
        before do
          delete_class('5K')
        end

        it 'the pupils are gone, too' do
          within('#menu') { click_link('Schüler') }
          within('section.sgh-elternverteiler-schüler') do
            expect(page).to_not have_content('Bart')
          end
        end

        it 'the pupils parents are gone, too' do
          within('#menu') { click_link('Eltern') }
          within('section.sgh-elternverteiler-erziehungsberechtigter') do
            expect(page).to_not have_content('Homer')
          end
        end
      end
    end

    context 'J1 exists' do
      before do
        create_klassenstufe('J1')
        create_class('J1')
      end

      after do
        delete_class('J1')
        delete_klassenstufe('J1')
      end

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
