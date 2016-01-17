require 'CFPropertyList'
require 'deep_merge'
require 'yaml'

require_relative 'plister/version'
require_relative './plister/plist'
require_relative './plister/preferences'

module Plister
  class << self
    def preferences(path = nil)
      Plister::Preferences.new(path)
    end

    def user
      @user ||= `logname`.strip
    end

    def uuid
      @uuid ||= begin
        uuid = `ioreg -rd1 -c IOPlatformExpertDevice`
        matches = uuid.match(/"IOPlatformUUID" = "([0-9A-F-]{36})"/)
        matches[1] if matches
      end
    end
  end
end
