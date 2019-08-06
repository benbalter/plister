# frozen_string_literal: true

require 'spec_helper'

describe Plister do
  it 'has a version number' do
    expect(Plister::VERSION).not_to be nil
  end

  it 'knows the user' do
    expect(subject.user).to eql(`whoami`.strip)
  end

  it 'inits the preferences' do
    expect(subject.preferences.class).to eql(Plister::Preferences)
  end

  it 'knows the uuid' do
    regex = /[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}/
    expect(subject.uuid).to match(regex)
  end
end
