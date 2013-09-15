require 'sqlite3'
require 'test/unit'

unless RUBY_VERSION >= "1.9"
  require 'iconv'
end

module SQLite3
  class TestCase < Test::Unit::TestCase
    unless RUBY_VERSION >= '1.9'
      undef :default_test
    end
  end
end
