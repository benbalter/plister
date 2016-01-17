module Plister
  class Plist
    attr_accessor :domain, :type
    TYPES = %w(user system host).freeze

    def initialize(domain, type: 'user')
      @domain = domain
      @type   = type.to_s
      fail ArgumentError, 'Invalid type' unless valid_type?
    end

    def preferences
      @preferences ||= CFPropertyList.native_types(list.value)
    end

    def preferences=(prefs)
      list.value = CFPropertyList.guess(prefs, convert_unknown_to_string: true)
      @preferenes = nil
      preferences
    end

    def merge(prefs)
      self.preferences = preferences.deep_merge(prefs)
    end

    def write
      fail IOError, "#{path} is not writable by #{Plister.user}" unless writable?
      list.save
    end

    private

    def path
      @path ||= begin
        case type
        when 'system'
          "/Library/Preferences/#{domain}.plist"
        when 'user'
          "/Users/#{Plister.user}/Library/Preferences/#{domain}.plist"
        when 'host'
          "/Users/#{Plister.user}/Library/preferences/ByHost/#{domain}.#{Plister.uuid}.plist"
        end
      end
    end

    def list
      fail IOError, "#{path} does not exist" unless exists?
      fail IOError, "#{path} is not readable by #{Plister.user}" unless readable?
      @list ||= CFPropertyList::List.new file: path
    end

    def exists?
      File.exist?(path)
    end

    def writable?
      File.writable?(path)
    end

    def readable?
      File.readable?(path)
    end

    def valid_type?
      TYPES.include?(type)
    end
  end
end
