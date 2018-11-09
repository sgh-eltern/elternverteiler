# frozen_string_literal: true

require_relative 'helper'
require 'que'

describe 'Lehrer', type: :feature do
  before do
    visit '/'
    within('#menu') { click_link('Lehrer') }
  end

  it 'has a page title' do
    expect(page).to have_content('Alle Lehrer')
  end

  it 'has an header' do
    within(:xpath, '//table[contains(@class, "sgh-elternverteiler-lehrer")]') do
      expect(page).to have_xpath('.//th')
    end
  end

  it 'has an empty list of Lehrer' do
    within(:xpath, '//table[contains(@class, "sgh-elternverteiler-lehrer")]') do
      expect(page).to_not have_xpath('.//td')
    end
  end

  context 'refreshing the list of Lehrer' do
    before do
      click_button('Aktualisieren')
    end

    it 'shows a flash message' do
      expect(page).to have_xpath('//aside')
    end

    it 'shows a flash message that contains a link to the new job' do
      expect(page).to have_xpath('//aside/a')
    end

    context 'the job queue is processing jobs' do
      before do
        @locker = Que::Locker.new(queues: ['lehrer'])
      end

      after do
        @locker.stop!
      end

      it 'has an non-empty list of Lehrer' do
        attempts = 0

        begin
          attempts += 1
          within(:xpath, '//table[contains(@class, "sgh-elternverteiler-lehrer")]') do
            expect(page).to have_xpath('.//td')
          end
        rescue RSpec::Expectations::ExpectationNotMetError
          if attempts > 10
            raise
          else
            refresh
            retry
          end
        end
      end
    end
  end
end
