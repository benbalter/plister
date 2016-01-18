$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'plister'
require 'fileutils'

def fixture_path(fixture = 'plist.plist')
  File.expand_path "./fixtures/#{fixture}", File.dirname(__FILE__)
end

def tmp_dir
  dir = File.expand_path '../tmp', File.dirname(__FILE__)
  FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
  dir
end

def tmp_file_path
  File.expand_path 'tmp.plist', tmp_dir
end
