# frozen_string_literal: true

module RoleHelpers
  def create_role(name)
    visit '/'
    within('#menu') { click_link('Rollen') }
    click_link('Anlegen')
    fill_in('Name', with: name)
    click_button('Anlegen')
  end

  def assign_role(klasse, name, role)
    visit '/'
    within('#menu') { click_link('Klassen') }
    within('.content') { click_link(klasse) }
    within('.content') { click_link('Hinzufügen') }

    find('#sgh-elternverteiler-amt_rolle_id').click
    select(role)

    find('#sgh-elternverteiler-amt_inhaber_id').click
    select(name)

    click_button('Speichern')
  end

  def delete_role(name)
    visit '/'
    within('#menu') { click_link('Rollen') }
    within('.content') do
      if page.has_link?(name)
        click_link(name)
        accept_alert { click_button('Löschen') }
      end
    end
  end
end
