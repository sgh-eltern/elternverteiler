# frozen_string_literal: true

require_relative 'helper'

describe 'Schüler', type: :feature do
  context 'Klasse 5S' do
    before(:all) do
      create_klassenstufe('9')
      create_class('9', 'S')
    end

    after(:all) do
      delete_class('9S')
      delete_klassenstufe('9')
    end

    context 'there are no pupils' do
      after { delete_pupil('Simpson', 'Bart', '9S') }

      it 'can create a new pupil' do
        create_pupil('Simpson', 'Bart', '9S')

        within('.sgh-elternverteiler-schüler') do
          expect(page).to have_content('Bart')
          expect(page).to have_content('Simpson')
        end
      end
    end

    context 'Bart exists' do
      before { create_pupil('Simpson', 'Bart', '9S') }
      after { delete_pupil('Simpson', 'Bart', '9S') }

      before do
        visit '/'
        within('#menu') { click_link('Schüler') }
        click_link('Simpson')
      end

      it 'has the last name' do
        expect(find('.sgh-elternverteiler-schüler')).to have_content('Simpson')
      end

      context "and is registered as Homer's son" do
        before do
          create_parent('Simpson', 'Homer')
          assign_parent('Simpson', 'Simpson, Homer')
        end

        after { delete_parent('Simpson', 'Homer') }

        it "lists Bart as Homer's son" do
          click_link('Simpson')
          expect(find('.sgh-elternverteiler-erziehungsberechtigter')).to have_content('Simpson')
        end

        context 'pressing the delete button' do
          before { accept_alert { click_button('Löschen') } }

          it 'removes the pupil' do
            expect(find('table.sgh-elternverteiler-schüler')).to_not have_content('Bart')
          end

          it 'removes his parents' do
            within('#menu') { click_link('Eltern') }
            expect(find('.sgh-elternverteiler-erziehungsberechtigter')).to_not have_content('Simpson')
          end
        end
      end

      context 'Editing Bart' do
        before do
          visit '/'
          within('#menu') { click_link('Schüler') }
          click_link('Simpson')
        end

        it 'has the new first name' do
          click_link('Bearbeiten')
          fill_in('Vorname', with: 'Bartholomew')
          click_button('Aktualisieren')
          expect(find('.sgh-elternverteiler-schüler')).to have_content('Bartholomew')
        end

        it 'has the new last name' do
          click_link('Bearbeiten')
          fill_in('Nachname', with: 'Simpsonian')
          click_button('Aktualisieren')
          expect(find('.sgh-elternverteiler-schüler')).to have_content('Simpsonian')
        end

        it 'has the new Klasse' do
          click_link('Bearbeiten')
          find('#sgh-elternverteiler-schüler_klasse_id').click
          select('9S')
          click_button('Aktualisieren')
          expect(find('.sgh-elternverteiler-schüler')).to have_content('9S')
        end
      end
    end
  end
end
