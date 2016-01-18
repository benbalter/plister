require 'spec_helper'

describe Plister::Plist do
  let(:user) { `whoami`.strip }
  let(:domain) { 'com.balter.ben' }
  subject { described_class.new domain }

  it 'knows the domain' do
    expect(subject.domain).to eql(domain)
  end

  it 'defaults to user plists' do
    expect(subject.type).to eql('user')
  end

  it 'accepts types' do
    subject = described_class.new(domain, type: 'system')
    expect(subject.type).to eql('system')
  end

  it 'validates types' do
    expect { described_class.new(domain, type: 'foo') }.to raise_error(ArgumentError)
  end

  context 'paths' do
    let(:types) do
      {
        'user' => %r{/Users/[a-z0-9]+/Library/Preferences/com.balter.ben.plist},
        'system' => %r{/Library/Preferences/com.balter.ben.plist},
        'host' => %r{/Users/[a-z0-9]+/Library/preferences/ByHost/com.balter.ben.[A-Z0-9-]+.plist}
      }
    end

    described_class::TYPES.each do |type|
      context 'type preferences' do
        subject { described_class.new domain, type: type }
        it 'builds the path' do
          expected = types[type]
          expect(subject.send(:path)).to match(expected)
        end
      end
    end
  end

  context 'stubbed path' do
    before do
      allow(subject).to receive(:path) { fixture_path }
    end

    after { subject.instance_variable_set('@preferences', nil) }

    it 'parses preferences' do
      expect(subject.preferences).to eql('Foo' => 'Bar')
    end

    it 'accepts preferences' do
      prefs = { 'foo2' => 'bar2' }
      subject.preferences = prefs
      expect(subject.preferences).to eql(prefs)
    end

    it 'merges' do
      prefs = { 'foo2' => 'bar2' }
      expected = { 'Foo' => 'Bar', 'foo2' => 'bar2' }
      subject.merge(prefs)
      expect(subject.preferences).to eql(expected)
    end

    it 'inits the list' do
      expect(subject.send(:list).class).to eql(CFPropertyList::List)
    end

    it 'knows if the file exists' do
      expect(subject.send(:exists?)).to eql(true)
    end

    context 'an invalid plist file' do
      before do
        allow(subject).to receive(:path) { '/tmp/plister.plist' }
      end

      it "knows the file doesn't exist" do
        expect(subject.send(:exists?)).to eql(false)
      end
    end

    context 'a temp file' do
      before do
        FileUtils.rm_rf tmp_file_path
        allow(subject).to receive(:path) { tmp_file_path }
        FileUtils.cp fixture_path, tmp_file_path
      end

      after { FileUtils.rm_rf tmp_file_path }

      it 'writes the file' do
        subject.preferences = { 'foo2' => 'bar2' }
        subject.write
        expect(File.exist?(tmp_file_path)).to eql(true)
        content = File.open(tmp_file_path).read
        expect(content).to match(/foo2/)
      end
    end
  end
end
