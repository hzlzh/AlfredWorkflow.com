require 'rbconfig'
# ruby 1.8.7 doesn't define RUBY_ENGINE
ruby_engine = defined?(RUBY_ENGINE) ? RUBY_ENGINE : 'ruby'
ruby_version = RbConfig::CONFIG["ruby_version"]
path = File.expand_path('..', __FILE__)
$:.unshift File.expand_path("#{path}/../#{ruby_engine}/#{ruby_version}/gems/json-1.7.7/lib")
$:.unshift File.expand_path("#{path}/../#{ruby_engine}/#{ruby_version}/gems/google-search-1.0.3/lib")
$:.unshift File.expand_path("#{path}/../#{ruby_engine}/#{ruby_version}/gems/nokogiri-1.5.7/lib")
