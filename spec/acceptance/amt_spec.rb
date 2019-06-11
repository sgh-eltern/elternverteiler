# frozen_string_literal: true

require_relative 'helper'

describe 'Ämter', type: :feature do
  before do
    visit '/'
    within('#menu') { click_link('Ämter') }
  end

  it 'has a page title' do
    expect(page).to have_content('Ämter')
  end

  context 'the role Klassenkasper exists' do
    before { create_role('Klassenkasper', 'kasper') }
    after { delete_role('Klassenkasper') }

    it 'lists the role' do
      expect(page).to have_content('Klassenkasper')
    end

    context 'Homer and 5a exist' do
      before do
        create_klassenstufe('5')
        create_class('5', 'A')
        create_pupil('Simpson', 'Bart', '5A')
        create_parent('Simpson', 'Homer', 'homer@simpson.name')
        assign_parent('Simpson', 'Simpson, Homer')
      end

      after do
        delete_parent('Simpson', 'Homer', 'homer@simpson.name')
        delete_pupil('Simpson', 'Bart', '5A')
        delete_class('5A')
        delete_klassenstufe('5')
      end

      it 'makes Homer the Klassenkasper of 5a' do
        visit '/'
        within('#menu') { click_link('Ämter') }
        within('.sgh-elternverteiler-ämter') { click_link('Klassenkasper') }
        within('.content') { click_link('Hinzufügen') }
        find('#sgh-elternverteiler-amtsperiode_klasse_id').click
        select('5A')

        find('#sgh-elternverteiler-amtsperiode_inhaber_id').click
        select('Simpson, Homer')

        click_button('Speichern')

        within('aside.success') { expect(page).to have_content('Homer Simpson ist jetzt Klassenkasper in der Klasse 5A') }
        within('.sgh-elternverteiler-amtsinhaber'){ expect(page).to have_content('Simpson, Homer') }
      end
    end

    context 'attempting to create another Amt with the same name' do
      before do
        create_role('Klassenkasper', 'kasper')
      end

      it 'provides details on the error' do
        within('aside.error') do
          expect(page).to have_content('Das Amt Klassenkasper existiert bereits')
        end
      end
    end

    context 'Klassenkasper is deleted' do
      before { delete_role('Klassenkasper') }

      it 'shows the list of all roles' do
        within('.header > h1') do
          expect(page).to have_content('Alle Ämter')
        end
      end

      it 'shows a success message' do
        within('aside.success') do
          expect(page).to have_content('Das Amt Klassenkasper wurde gelöscht')
        end
      end

      it 'no longer lists the role' do
        within('.sgh-elternverteiler-ämter') do
          expect(page).to_not have_content('Klassenkasper')
        end
      end
    end
  end
end
