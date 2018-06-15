# frozen_string_literal: true

require_relative 'helper'

describe 'Helper', type: :feature do
  context 'Klasse 5H exists' do
    before(:all) { create_class('5', 'H') }
    after(:all) { delete_class('5H') }

    context 'Bart does not exist' do
      after { delete_pupil('Simpson', 'Bart', '5H') }

      it 'creates Bart as pupil in 5H' do
        create_pupil('Simpson', 'Bart', '5H')

        within('#menu') { click_link('Schüler') }
        within(find('.sgh-elternverteiler-schüler')) do
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
          within(find('.sgh-elternverteiler-schüler')) do
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
