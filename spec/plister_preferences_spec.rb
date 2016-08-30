require 'spec_helper'

describe Plister::Preferences do
  let(:user) { `whoami`.strip }

  it "defaults to the user's home dir" do
    expected = "/Users/#{user}/.osx.yml"
    expect(subject.path).to eql(expected)
  end

  it 'accepts a path' do
    subject = described_class.new 'foo.yml'
    expect(subject.path).to eql('foo.yml')
  end

  context 'with stubbed preferences' do
    subject { described_class.new fixture_path('prefs.yml') }

    it 'loads the file contents' do
      expect(subject.send(:contents)).to match(/key: value/)
    end

    it 'loads the preferences' do
      data = subject.send(:data)
      expected = { 'key' => 'value' }
      expect(data['user']['com.balter.ben']).to eql(expected)
    end

    it 'builds to domain list' do
      expect(subject.domains).to eql(['com.balter.ben'])
    end

    context 'writing' do
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
        subject.set!
        expect(File.exist?(plist_path))
      end
    end
  end

  context 'with an empty preferene file' do
    it "Doesn't blow up" do
      subject.instance_variable_set('@contents', '')
      expect(subject.domains).to eql([])
    end
  end
end
