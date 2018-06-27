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
    before { create_role('Klassenkasper') }
    after { delete_role('Klassenkasper') }

    it 'lists the role' do
      within('.sgh-elternverteiler-amt') do
        expect(page).to have_content('Klassenkasper')
      end
    end

    context 'attempting to create another Amt with the same name' do
      before do
        create_role('Klassenkasper')
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
