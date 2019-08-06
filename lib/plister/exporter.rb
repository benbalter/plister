# frozen_string_literal: true

module Plister
  class Exporter
    attr_reader :path

    def initialize(path = nil)
      @path = path || "/Users/#{Plister.user}/.osx.yml"
    end

    def export
      File.write path, to_s
    end

    def to_s
      Psych.dump(preferences)
    end

    private

    def types
      @types ||= {
        system: '/Library/Preferences',
        user: "/Users/#{Plister.user}/Library/Preferences",
        host: "/Users/#{Plister.user}/Library/preferences/ByHost"
      }
    end

    def paths
      @paths ||= begin
        paths = {}
        # Note: We can't use to_h here because OS X ships with Ruby 2.0.x
        # which doesn't have the Array#to_h method
        types.each { |type, path| paths[type] = Dir["#{path}/*.plist"] }
        paths
      end
    end

    def preferences
      @preferences ||= begin
        output = {}
        paths.each do |type, plist_paths|
          plists = plist_paths.map { |domain| Plist.new domain, type: type }
          plists.select!(&:readable?)
          # Note: We can't use to_h here because OS X ships with Ruby 2.0.x
          # which doesn't have the Array#to_h method
          output[type.to_s] ||= {}
          plists.each { |p| output[type.to_s][p.domain] = p.to_h }
        end
        output
      end
    end
  end
end
