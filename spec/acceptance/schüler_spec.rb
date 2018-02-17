# frozen_string_literal: true

require_relative 'helper'

describe 'Schüler', type: :feature do
  context 'Klasse 5C' do
    before(:all) { create_class('5', 'C') }

    it 'can create a new pupil' do
      last_name = SecureRandom.uuid
      first_name = SecureRandom.uuid
      create_pupil(last_name, first_name, '5C')
      expect(page).to have_content first_name
      expect(page).to have_content last_name
    end

    context "Bart's page" do
      before(:all){ create_pupil('Simpson', 'Bart', '5C')}

      before do
        visit '/'
        within('#menu') { click_link('Schüler') }
        click_link('Bart')
      end

      it 'has the last name' do
        expect(page).to have_content 'Simpson'
      end

      xit 'lists parents' do
        click_link('Simpson')
        expect(page).to have_content 'springfield.us'
      end

      context 'pressing the delete button' do
        before { click_button('Löschen') }

        it 'removes the pupil' do
          within('table') do
            expect(page).to_not have_content 'Bart'
          end
        end

        xit 'removes his parents' do
          within('#menu') { click_link('Eltern') }
          expect(page).to_not have_content 'Simpson'
        end
      end
    end
  end
end
