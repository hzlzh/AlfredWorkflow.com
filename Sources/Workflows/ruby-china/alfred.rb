require 'rubygems'
require 'plist'
require 'fileutils'

class AlfredInit
  attr_reader :query

  def initialize(query)
    @query = query
    if bundle_id
      init_dir(temp_storage_path)
      init_dir(storage_path)
    end
  end

  def plist_path
    File.join(File.dirname(__FILE__), 'info.plist')
  end

  def plist
    @plist ||= Plist::parse_xml(plist_path)
  end

  def settings_path
    File.join(storage_path, 'settings.plist')
  end

  def settings
    @settings ||= Plist::parse_xml(settings_path) || {}
  end

  def store_settings!
    File.open(settings_path, 'w') { |f| f.puts settings.to_plist }
  end

  # The plist bundleid as set by the workflow UI. Returns nil if not set.
  def bundle_id
    plist['bundleid'] if plist['bundleid'] != ''
  end

  # Volatile storage directory for this bundle
  def temp_storage_path
    assert_path_environment
    "#{ENV['HOME']}/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/#{bundle_id}"
  end

  # Non-volatile storage directory for this bundle
  def storage_path
    assert_path_environment
    "#{ENV['HOME']}/Library/Application Support/Alfred 2/Workflow Data/#{bundle_id}"
  end

  # Make sure bundle_id and ENV['HOME'] have reasonable values
  def assert_path_environment
    raise "Workflow has no bundle id set" unless bundle_id
    raise "HOME directory is unknown" unless ENV['HOME'] and ENV['HOME'].size > 1
  end

  def init_dir(path)
    FileUtils.mkdir_p(path)
  end

  def log(msg)
    console_log(msg)
  end
end
