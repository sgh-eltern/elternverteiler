# frozen_string_literal: true

require_relative 'helper'

describe 'Verteiler', type: :feature do
  before(:all) do
    create_klassenstufe('5')
    create_class('5', 'V')
    create_pupil('Simpson', 'Bart', '5V')
    create_parent('Simpson', 'Homer', 'homer@simpson.name')
    assign_parent('Simpson', 'Simpson, Homer')
  end

  after(:all) do
    delete_parent('Simpson', 'Homer', 'homer@simpson.name')
    delete_pupil('Simpson', 'Bart', '5V')
    delete_class('5V')
    delete_klassenstufe('5')
  end

  before do
    visit '/'
    within('#menu') { click_link('Verteiler') }
  end

  it 'has Klassen' do
    expect(page).to have_content('Klassen')
  end

  it 'has the address of the Elternvertreter of 5V' do
    within('.sgh-elternverteiler-klasse-elternvertreter') do
      expect(page).to have_link('elternvertreter-5v@schickhardt-gymnasium-herrenberg.de')
    end
  end

  it 'links to the distribution list details for Elternvertreter of 5V' do
    within('.sgh-elternverteiler-klasse-elternvertreter') do
      expect(page).to have_link('Elternvertreter der Klasse 5V',
      href: '/verteiler/elternvertreter-5v')
    end
  end

  it 'has the address of the Eltern of 5V' do
    within('.sgh-elternverteiler-klasse-eltern') do
      expect(page).to have_link('eltern-5v')
    end
  end

  it 'links to the distribution list details for Eltern of 5V' do
    within('.sgh-elternverteiler-klasse-eltern') do
      expect(page).to have_link('Eltern der Klasse 5V',
      href: '/verteiler/eltern-5v')
    end
  end

  it 'has Klassenstufen' do
    expect(page).to have_content('Klassenstufen')

    within('.sgh-elternverteiler-klassenstufe-elternvertreter') do
      expect(page).to have_link('Elternvertreter der Klassenstufe 5')
      expect(page).to have_link('elternvertreter-5')
    end

    within('.sgh-elternverteiler-klassenstufe-eltern') do
      expect(page).to have_link('Eltern der Klassenstufe 5')
      expect(page).to have_link('eltern-5')
    end
  end

  it 'has all Eltern' do
    within('.sgh-elternverteiler-sonstige') do
      expect(page).to have_link('Alle Eltern')
      expect(page).to have_link('eltern')
    end
  end

  it 'has the Elternbeirat' do
    within('.sgh-elternverteiler-sonstige') do
      expect(page).to have_link('Elternbeirat')
      expect(page).to have_link('elternbeirat')
    end
  end

  it 'has the Elternvertreter in der Schulkonferenz' do
    within('.sgh-elternverteiler-sonstige') do
      expect(page).to have_link('Elternvertreter in der Schulkonferenz')
    end
  end

  it 'has the Elternbeiratsvorsitzende' do
    within('.sgh-elternverteiler-sonstige') do
      expect(page).to have_link('Elternbeiratsvorsitzende')
    end
  end

  context 'Homer is the primary Elternvertreter of 5V' do
    before(:all) do
      create_role('1.EV')
      assign_role('5V', 'Simpson, Homer', '1.EV')
      within('#menu') { click_link('Verteiler') }
    end

    it 'links to the mailing list for Eltern' do
      within('.sgh-elternverteiler-sonstige') do
        expect(page).to have_link('Alle Eltern')
      end
    end

    it 'links to the mailing list for Elternvertreter' do
      within('.sgh-elternverteiler-klasse-elternvertreter') do
        expect(page).to have_link('Elternvertreter')
      end
    end

    context 'Ned is the primary Elternvertreter of 5W' do
      before(:all) do
        create_class('5', 'W')
        create_pupil('Flanders', 'Rod', '5W')
        create_parent('Flanders', 'Ned', 'flanders@firstchurch.org')
        assign_parent('Flanders', 'Flanders, Ned')
        assign_role('5W', 'Flanders, Ned', '1.EV')
        within('#menu') { click_link('Verteiler') }
      end

      it 'links to the mailing list for Elternvertreter of the Klassenstufe' do
        within('.sgh-elternverteiler-klassenstufe-elternvertreter') do
          expect(page).to have_link('Elternvertreter der Klassenstufe 5')
        end
      end

      it 'links to the mailing list for Eltern of the Klassenstufe' do
        within('.sgh-elternverteiler-klassenstufe-eltern') do
          expect(page).to have_link('Eltern der Klassenstufe 5')
        end
      end
    end
  end
end
