# frozen_string_literal: true

require_relative 'helper'

describe 'Schüler', type: :feature do
  context 'Klasse 5S' do
    before(:all) { create_class('5', 'S') }

    let(:simpson) { "Simpson-#{rand(1000)}" }
    let(:bart) { "Bart-#{rand(1000)}" }

    it 'can create a new pupil' do
      create_pupil(simpson, bart, '5S')
      within(find('.sgh-elternverteiler-schüler')) do
        expect(page).to have_content(bart)
        expect(page).to have_content(simpson)
      end
    end

    context 'Bart exists' do
      before { create_pupil(simpson, bart, '5S') }

      before do
        visit '/'
        within('#menu') { click_link('Schüler') }
        click_link(simpson)
      end

      it 'has the last name' do
        expect(find('.sgh-elternverteiler-schüler')).to have_content(simpson)
      end

      context "and is registered as Homer's son" do
        let(:homer) { "Homer-#{rand(1000)}" }

        before do
          create_parent(simpson, homer)
          assign_parent(simpson, "#{simpson}, #{homer}")
        end

        it "lists Bart as Homer's son" do
          click_link(simpson)
          expect(find('.sgh-elternverteiler-erziehungsberechtigter')).to have_content(simpson)
        end

        context 'pressing the delete button' do
          before { accept_alert { click_button('Löschen') } }

          it 'removes the pupil' do
            expect(find('table.sgh-elternverteiler-schüler')).to_not have_content(bart)
          end

          it 'removes his parents' do
            within('#menu') { click_link('Eltern') }
            expect(find('.sgh-elternverteiler-erziehungsberechtigter')).to_not have_content(simpson)
          end
        end
      end

      context 'Editing Bart' do
        let(:bartholomew) { "Bartholomew-#{rand(1000)}" }
        let(:simpsonian) { "Simpsonian-#{rand(1000)}" }
        let(:stufe) { rand(1..12) }
        let(:zug) { ('A'..'Z').to_a.sample }
        let(:klasse) { "#{stufe}#{zug}" }

        before do
          create_class(stufe, zug)
          visit '/'
          within('#menu') { click_link('Schüler') }
          click_link(simpson)
        end

        it 'has the new first name' do
          click_link('Bearbeiten')
          fill_in('Vorname', with: bartholomew)
          click_button('Aktualisieren')
          expect(find('.sgh-elternverteiler-schüler')).to have_content(bartholomew)
        end

        it 'has the new last name' do
          click_link('Bearbeiten')
          fill_in('Nachname', with: simpsonian)
          click_button('Aktualisieren')
          expect(find('.sgh-elternverteiler-schüler')).to have_content(simpsonian)
        end

        it 'has the new class' do
          click_link('Bearbeiten')
          find('#sgh-elternverteiler-schüler_klasse_id').click
          select(klasse)
          click_button('Aktualisieren')
          expect(find('.sgh-elternverteiler-schüler')).to have_content(klasse)
        end
      end
    end
  end
end
