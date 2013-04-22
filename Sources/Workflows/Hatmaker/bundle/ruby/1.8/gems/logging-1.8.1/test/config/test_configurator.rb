
require File.expand_path('../setup', File.dirname(__FILE__))

module TestLogging
module TestConfig

  class TestConfigurator < Test::Unit::TestCase
    include LoggingTestCase

    def test_configuration
      begin
        load Logging.path(%w[data logging.rb])
      rescue Exception => err
        flunk err.inspect
      end

      levels = {
        'deb' => 0,
        'inf' => 1,
        'prt' => 2,
        'wrn' => 3,
        'err' => 4,
        'fat' => 5
      }
      assert_equal levels, Logging::LEVELS
      assert_equal :inspect, Logging::OBJ_FORMAT

      hash = Logging::Repository.instance.instance_variable_get(:@h)
      assert hash.has_key?('A::B::C')
      assert hash.has_key?('yourlogger')
    end

    def test_simple_configuration
      begin
        load Logging.path(%w[data simple_logging.rb])
      rescue Exception => err
        flunk err.inspect
      end

      levels = {
        'debug' => 0,
        'info'  => 1,
        'warn'  => 2,
        'error' => 3,
        'fatal' => 4
      }
      assert_equal levels, Logging::LEVELS
      assert_equal false, Logging.const_defined?('OBJ_FORMAT')

      root = Logging::Logger.root
      assert_equal 1, root.level
    end

    def test_bad_appender_configuration
      assert_raise(Logging::Config::Configurator::Error) {
        load Logging.path(%w[data bad_logging_1.rb])
      }
    end

    def test_bad_layout_configuration
      assert_raise(Logging::Config::Configurator::Error) {
        load Logging.path(%w[data bad_logging_2.rb])
      }
    end
  end

end  # module TestConfig
end  # module TestLogging

