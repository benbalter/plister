require 'spec_helper'

describe 'Plister::Bin' do
  let(:user) { `whoami`.strip }
  let(:plist_path) { "/Users/#{user}/Library/Preferences/com.balter.ben.plist" }

  before do
    FileUtils.rm_rf(plist_path) if File.exist?(plist_path)
    FileUtils.mkdir_p File.dirname(plist_path)
    FileUtils.cp fixture_path, plist_path
  end

  after do
    FileUtils.rm_rf(plist_path) if File.exist?(plist_path)
  end

  it 'sets the preferences' do
    bin = File.expand_path '../bin/plister', File.dirname(__FILE__)
    `#{bin} #{fixture_path('prefs.yml')}`
    expect(File.exist?(plist_path))
  end
end
