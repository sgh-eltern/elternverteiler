# frozen_string_literal: true

require 'sgh/elternverteiler/mailing_list'

describe MailingList do
  subject { described_class.new(
    title: 'Namenspatron',
    address: 'wilhelm',
    members: [
        'rektor@example.com',
        'hausmeister@example.net'
      ]
    )
  }

  it 'has a default address' do
    expect(subject.address).to eq 'wilhelm'
  end

  it 'has a short address' do
    expect(subject.address(:short)).to eq 'wilhelm'
  end

  it 'has a long address' do
    expect(subject.address(:long)).to eq 'wilhelm@schickhardt-gymnasium-herrenberg.de'
  end

  it 'rejects unknown address formats' do
    expect { subject.address(:something) }.to raise_error(StandardError)
  end
end
