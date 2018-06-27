# frozen_string_literal: true

module KlassenstufeHelpers
  def create_klassenstufe(name)
    visit '/'
    within('#menu') { click_link('Klassenstufen') }
    click_link('Anlegen')
    fill_in('Name', with: name)
    click_button('Anlegen')
  end

  def delete_klassenstufe(name)
    visit '/'
    within('#menu') { click_link('Klassenstufen') }
    within('.content') do
      if page.has_link?(name)
        click_link(name)
        accept_alert { click_button('Löschen') }
      end
    end
  end
end
