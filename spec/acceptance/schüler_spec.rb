# frozen_string_literal: true

require_relative 'helper'

describe 'Schüler', type: :feature do
  def create_pupil(last, first, clazz)
    visit '/'
    within('#menu') { click_link('Schüler') }
    click_link('Anlegen')
    fill_in('Vorname', with: first)
    fill_in('Nachname', with: last)
    find('#SGH--Elternverteiler--Schüler_klasse_id').click
    select(clazz)
    click_button('Anlegen')
  end

  def create_class(stufe, zug=nil)
    visit '/'
    within('#menu') { click_link('Klassen') }
    click_link('Anlegen')
    fill_in('Stufe', with: stufe)
    fill_in('Zug', with: zug)
    click_button('Anlegen')
  end

  before(:all) do
    # bring to foreground
    page.switch_to_window(page.current_window)
  end

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

      it 'lists parents' do
        click_link('Simpson')
        expect(page).to have_content 'springfield.us'
      end

      context 'pressing the delete button' do
        before { click_button('Löschen') }

        it 'removes the pupil' do
          expect(page).to_not have_content 'Bart'
        end

        it 'removes his parents' do
          within('#menu') { click_link('Eltern') }
          expect(page).to_not have_content 'Simpson'
        end
      end
    end
  end
end
