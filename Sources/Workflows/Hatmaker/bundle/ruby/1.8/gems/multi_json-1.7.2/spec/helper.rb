require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

require 'multi_json'
require 'rspec'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def silence_warnings
  old_verbose, $VERBOSE = $VERBOSE, nil
  yield
ensure
  $VERBOSE = old_verbose
end

def macruby?
  defined?(RUBY_ENGINE) && RUBY_ENGINE == 'macruby'
end

def jruby?
  defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'
end