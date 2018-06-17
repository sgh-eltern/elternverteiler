module ParentHelpers
  def create_parent(last, first=nil, email=nil)
    visit '/'
    within('#menu') { click_link('Eltern') }
    click_link('Anlegen')
    fill_in('Nachname', with: last)
    fill_in('Vorname', with: first)
    fill_in('Mail', with: email)
    click_button('Anlegen')
  end

  def assign_parent(child, parent)
    visit '/'
    within('#menu') { click_link('Schüler') }
    click_link(child)
    click_link('Hinzufügen')
    find('#sgh-elternverteiler-erziehungsberechtigung_erziehungsberechtigter_id').click
    select(parent)
    click_button('Speichern')
  end

  def delete_parent(last, first=nil, email=nil)
    visit '/'
    within('#menu') { click_link('Eltern') }
    within('.content') do
      if page.has_link?(last)
        click_link(last)
        accept_alert { click_button('Löschen') }
      end
    end
  end
end
