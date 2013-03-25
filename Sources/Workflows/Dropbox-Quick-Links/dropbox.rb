require 'dropbox-api'
require 'yaml'
require 'base64'
require 'alfred'

bundle_settings = YAML::load(IO.read("bundle_settings.yml"))

Dropbox::API::Config.app_key    = Base64.decode64 bundle_settings['dropbox_app_key']
Dropbox::API::Config.app_secret = Base64.decode64 bundle_settings['dropbox_app_secret']
Dropbox::API::Config.mode       = 'dropbox'

module Dropbox
  def self.host_db
    IO.read(File.join(ENV['HOME'], '.dropbox', 'host.db'))
  end

  def self.root
    @root ||= Base64.decode64(host_db.lines.to_a[1])
  end

  # Return true if filepath is within the Dropbox root folder
  def self.file?(filepath)
    filepath[0...(root.size)] == root
  end

  def self.relative_to_root(filepath)
    filepath[(root.size)..-1] if file?(filepath)
  end

  def self.dropbox_yml
    File.join(AlfredInit.new.storage_path, 'dropbox.yml')
  end

  def self.settings
    @settings ||= YAML::load(IO.read(dropbox_yml))
  end

  def self.overwrite_settings(settings)
    File.open(dropbox_yml, "w") do |file|
      file.write YAML::dump(settings)
    end
  end

  def self.client
    @client ||= Dropbox::API::Client.new(
      :token  => settings['access_token'],
      :secret => settings['access_secret']
    )
  end

  def self.authorized?
    settings
    true
  rescue Errno::ENOENT => e
    false
  end
end