# frozen_string_literal: true

require_relative 'helper'

describe 'Schüler', type: :feature do
  context 'Klasse 5C' do
    before(:all) { create_class('5', 'C') }

    # instead of creating a fresh database for every example, we create unique names
    let(:simpson) { "Simpson-#{rand(1000)}" }
    let(:bart) { "Bart-#{rand(1000)}" }

    it 'can create a new pupil' do
      create_pupil(simpson, bart, '5C')
      expect(page).to have_content(bart)
      expect(page).to have_content(simpson)
    end

    context 'Bart exists' do
      before { create_pupil(simpson, bart, '5C') }

      before do
        visit '/'
        within('#menu') { click_link('Schüler') }
        click_link(simpson)
      end

      it 'has the last name' do
        expect(page).to have_content(simpson)
      end

      context "and is registered as Homer's son" do
        let(:homer) { "Homer-#{rand(1000)}" }

        before do
          create_parent(simpson, homer)
          assign_parent(simpson, "#{simpson}, #{homer}")
        end

        it "lists Bart as Homer's son" do
          click_link(simpson)
          expect(page).to have_content(simpson)
        end

        context 'pressing the delete button' do
          before { click_button('Löschen') }

          it 'removes the pupil' do
            within('table') do
              expect(page).to_not have_content(bart)
            end
          end

          it 'removes his parents' do
            within('#menu') { click_link('Eltern') }
            expect(page).to_not have_content(simpson)
          end
        end
      end
    end
  end
end
