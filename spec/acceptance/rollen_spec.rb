# frozen_string_literal: true

require_relative 'helper'

describe 'Rollen', type: :feature do
  before do
    visit '/'
    within('#menu') { click_link('Rollen') }
  end

  it 'has a page title' do
    expect(page).to have_content('Rollen')
  end

  context 'the role Klassenkasper exists' do
    before { create_role('Klassenkasper') }
    after { delete_role('Klassenkasper') }

    it 'lists the role' do
      within('.sgh-elternverteiler-rolle') do
        expect(page).to have_content('Klassenkasper')
      end
    end

    xit 'refuses to create another role with the same name' do
      create_role('Klassenkasper')
      expect(page).to have_content('Sorry - eine Rolle mit dem Namen Klassenkasper existiert bereits')
    end

    context 'Klassenkasper is deleted' do
      before { delete_role('Klassenkasper') }

      it 'shows the list of all roles' do
        within('.header > h1') do
          expect(page).to have_content('Alle Rollen')
        end
      end

      it 'shows a success message' do
        within('aside.success') do
          expect(page).to have_content('Die Rolle Klassenkasper wurde gelöscht')
        end
      end

      it 'no longer lists the role' do
        within('.sgh-elternverteiler-rollen') do
          expect(page).to_not have_content('Klassenkasper')
        end
      end
    end
  end
end
