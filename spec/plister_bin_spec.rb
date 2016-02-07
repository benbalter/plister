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
    FileUtils.rm_rf(tmp_dir) if Dir.exist?(tmp_dir)
  end

  def bin
    @bin ||= File.expand_path '../bin/plister', File.dirname(__FILE__)
  end

  it 'sets the preferences' do
    `#{bin} #{fixture_path('prefs.yml')}`
    expect(File.exist?(plist_path))
  end

  it 'display the version' do
    version = `#{bin} --version`.strip
    expect(version).to eql(Plister::VERSION)
  end

  it 'displays help information' do
    help = `#{bin} --help`
    expect(help).to match(/usage/i)
  end

  context 'dumping' do
    it 'dumps preferences to STDOUT' do
      prefs = `#{bin} --stdout`
      expect(prefs).to match(/com\.apple/)
    end

    it 'dumps prefernces to a file' do
      path = File.expand_path 'prefs.yml', tmp_dir
      `#{bin} #{path} --dump`
      expect(File.exist?(path))
      prefs = File.open(path).read
      expect(prefs).to match(/com\.apple/)
    end
  end
end
