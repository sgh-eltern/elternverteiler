# frozen_string_literal: true

require 'spec_helper'

describe Fach do
  it 'has a forme namespace' do
    expect(subject.forme_namespace).to eq('sgh-elternverteiler-fach')
  end

  it 'must not allow a duplicate name'
  it 'must not allow a duplicate Kürzel'
  it 'has a string representation'
  it 'has a name'
  it 'has a mailing list'
end
