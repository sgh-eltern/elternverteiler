module PupilHelpers
  def create_pupil(last, first, clazz)
    visit '/'
    within('#menu') { click_link('Schüler') }
    click_link('Anlegen')
    fill_in('Vorname', with: first)
    fill_in('Nachname', with: last)
    find('#sgh-elternverteiler-schüler_klasse_id').click
    select(clazz)
    click_button('Anlegen')
  end

  def delete_pupil(last, first, clazz)
    visit '/'
    within('#menu') { click_link('Klassen') }
    within('.content') { click_link(clazz) }
    within('.sgh-elternverteiler-schüler') do
      # TODO: This ignores the pupil's first name
      return unless page.has_link?(last)
      click_link(last)
    end

    within('.sgh-elternverteiler-schüler-form') do
      accept_alert { click_button('Löschen') }
    end
  end
end
