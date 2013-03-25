def jruby?
  defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'
end

def macruby?
  defined?(RUBY_ENGINE) && RUBY_ENGINE == 'macruby'
end

unless ENV['CI'] || macruby?
  require 'simplecov'
  SimpleCov.start do
    add_filter 'spec'
  end
end

require 'multi_json'
require 'rspec'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

class MockDecoder
  def self.load(string, options={})
    {'abc' => 'def'}
  end

  def self.dump(string)
    '{"abc":"def"}'
  end
end

class TimeWithZone
  def to_json(options={})
    "\"2005-02-01T15:15:10Z\""
  end
end
