
# Equivalent to a header guard in C/C++
# Used to prevent the class/module from being loaded more than once
unless defined? LOGGING_TEST_SETUP
LOGGING_TEST_SETUP = true

require 'rubygems'
require 'test/unit'
begin
  require 'turn'
rescue LoadError; end

# This line is needed for Ruby 1.9 -- hashes throw a "KeyError" in 1.9
# whereas they throw an "IndexError" in 1.8
#
KeyError = IndexError if not defined? KeyError

require File.join(File.dirname(__FILE__), %w[.. lib logging])


module TestLogging
module LoggingTestCase

  TMP = 'tmp'

  def setup
    super
    Logging.reset
    FileUtils.rm_rf TMP
    FileUtils.mkdir TMP
  end

  def teardown
    super
    FileUtils.rm_rf TMP
  end

end  # LoggingTestCase
end  # TestLogging

end  # defined?

