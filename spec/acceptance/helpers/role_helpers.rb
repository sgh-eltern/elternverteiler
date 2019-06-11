# frozen_string_literal: true

module RoleHelpers
  def create_role(name, mail)
    visit '/'
    within('#menu') { click_link('Ämter') }
    click_link('Anlegen')
    fill_in('Name', with: name)
    fill_in('Mail', with: mail)
    click_button('Anlegen')
  end

  def assign_role(klasse, name, role)
    visit '/'
    within('#menu') { click_link('Klassen') }
    within('.content') { click_link(klasse) }
    within('.content') { click_link('Hinzufügen') }

    find('#sgh-elternverteiler-amtsperiode_amt_id').click
    select(role)

    find('#sgh-elternverteiler-amtsperiode_inhaber_id').click
    select(name)

    click_button('Speichern')
  end

  def delete_role(name)
    visit '/'
    within('#menu') { click_link('Ämter') }
    within('.content') do
      if page.has_link?(name)
        click_link(name)
        accept_alert { click_button('Löschen') }
      end
    end
  end
end
