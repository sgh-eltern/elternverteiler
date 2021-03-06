# frozen_string_literal: true

module ClassHelpers
  def create_class(stufe, zug=nil)
    visit '/'
    within('#menu') { click_link('Klassen') }
    click_link('Anlegen')
    find('#sgh-elternverteiler-klasse_stufe_id').click
    select(stufe)
    fill_in('Zug', with: zug)
    click_button('Anlegen')
  end

  def delete_class(name)
    visit '/'
    within('#menu') { click_link('Klassen') }
    within('.content') do
      if page.has_link?(name)
        click_link(name)
        accept_alert { click_button('Löschen') }
      end
    end
  end
end
