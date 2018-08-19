# frozen_string_literal: true

require_relative 'helper'

describe 'Helper', type: :feature do
  context 'Klassenstufe 5 does not exist yet' do
    it 'creates it' do
      create_klassenstufe('5')

      within('#menu') { click_link('Klassenstufen') }
      within('.sgh-elternverteiler-klassenstufen') do
        expect(page).to have_content('5')
      end
    end
  end

  context 'Klassenstufe 5 exists' do
    before { create_klassenstufe('5') }
    after { delete_klassenstufe('5') }

    it 'deletes it' do
      delete_klassenstufe('5')

      within('#menu') { click_link('Klassenstufen') }
      within('.sgh-elternverteiler-klassenstufen') do
        expect(page).to_not have_content('5')
      end
    end

    context 'Klasse 5H exists' do
      before { create_class('5', 'H') }
      after { delete_class('5H') }

      context 'Bart does not exist' do
        after { delete_pupil('Simpson', 'Bart', '5H') }

        it 'creates Bart as pupil in 5H' do
          create_pupil('Simpson', 'Bart', '5H')

          within('#menu') { click_link('Schüler') }
          within('section.sgh-elternverteiler-schüler') do
            expect(page).to have_content('Bart')
          end
        end
      end

      context 'Bart is a pupil in 5H' do
        before { create_pupil('Simpson', 'Bart', '5H') }
        after { delete_pupil('Simpson', 'Bart', '5H') }

        describe 'deleting Bart' do
          before { delete_pupil('Simpson', 'Bart', '5H') }

          it 'removes Bart from the list' do
            within('#menu') { click_link('Schüler') }
            within('section.sgh-elternverteiler-schüler') do
              expect(page).to_not have_content('Bart')
            end
          end

          it 'does not touch Klasse 5H' do
            within('#menu') { click_link('Klassen') }
            within('.sgh-elternverteiler-klassen') do
              expect(page).to have_content '5H'
            end
          end
        end
      end
    end
  end

  context 'Homer does not exist yet' do
    after do
      delete_parent('Simpson', 'Homer', 'homer@simpson.name')
    end

    it 'creates Homer' do
      create_parent('Simpson', 'Homer', 'homer@simpson.name')

      within('#menu') { click_link('Eltern') }
      within('section.sgh-elternverteiler-erziehungsberechtigter') do
        expect(page).to have_content('Homer')
      end
    end
  end

  context 'Homer exists' do
    before { create_parent('Simpson', 'Homer', 'homer@simpson.name') }
    after { delete_parent('Simpson', 'Homer', 'homer@simpson.name') }

    it 'removes Homer' do
      delete_parent('Simpson', 'Homer', 'homer@simpson.name')
      within('#menu') { click_link('Eltern') }
      within('section.sgh-elternverteiler-erziehungsberechtigter') do
        expect(page).to_not have_content('Homer')
      end
    end
  end
end
