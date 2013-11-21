($LOAD_PATH << File.expand_path("..", __FILE__)).uniq!

@skip_load_apple_tv_converter ||= false

require "rubygems" unless defined? Gem
require "bundle/bundler/setup"
require 'rubygems/gem_runner'
require 'yaml'
require 'shellwords'
require File.expand_path(File.join(File.dirname(__FILE__), 'functions'))

# Install Alfred's workflow gem and dependencies
load_and_install_local_gem 'plist'
load_and_install_local_gem 'alfred-workflow'
require "alfred"

unless @skip_load_apple_tv_converter
  # Load (and install if needed) the Apple TV Converter gem
  load_and_install_remote_gem 'apple-tv-converter'
end

# Hack to convert to an expected string
@command_line_arguments = Shellwords.shellsplit(ARGV.join)
# Hack to remove the initial "[$$$" or "[~~~" and the final "]" to work around Mavericks quirks
@command_line_arguments = @command_line_arguments.join(' ').gsub(/^\[(\\?(?:\$|\~))*/, '').gsub(/\]$/, '').strip.gsub(/\n/, '')