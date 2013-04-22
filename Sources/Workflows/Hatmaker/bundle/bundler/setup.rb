require 'rbconfig'
# ruby 1.8.7 doesn't define RUBY_ENGINE
ruby_engine = defined?(RUBY_ENGINE) ? RUBY_ENGINE : 'ruby'
ruby_version = RbConfig::CONFIG["ruby_version"]
path = File.expand_path('..', __FILE__)
$:.unshift File.expand_path("#{path}/../#{ruby_engine}/#{ruby_version}/gems/little-plugger-1.1.3/lib")
$:.unshift File.expand_path("#{path}/../#{ruby_engine}/#{ruby_version}/gems/multi_json-1.7.2/lib")
$:.unshift File.expand_path("#{path}/../#{ruby_engine}/#{ruby_version}/gems/logging-1.8.1/lib")
$:.unshift File.expand_path("#{path}/../#{ruby_engine}/#{ruby_version}/gems/plist-3.1.0/lib")
$:.unshift File.expand_path("#{path}/../#{ruby_engine}/#{ruby_version}/gems/alfred-workflow-1.7.0/lib")
$:.unshift File.expand_path("#{path}/../#{ruby_engine}/#{ruby_version}/gems/oj-2.0.10/lib")
$:.unshift File.expand_path("#{path}/../#{ruby_engine}/#{ruby_version}/gems/oj-2.0.10/ext")
