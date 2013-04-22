
require File.expand_path('../setup', File.dirname(__FILE__))

module TestLogging
module TestConfig

  class TestYamlConfigurator < Test::Unit::TestCase
    include LoggingTestCase

    def test_class_load
      assert_raise(::Logging::Config::YamlConfigurator::Error) {
        ::Logging::Config::YamlConfigurator.load(Object.new)
      }

      begin
        fd = File.open('data/logging.yaml','r')
        assert_nothing_raised {
          ::Logging::Config::YamlConfigurator.load(fd)
        }
      ensure
        fd.close
      end
    end

    def test_initialize
      io = StringIO.new
      io << YAML.dump({:one => 1, :two => 2, :three => 3})
      io.seek 0

      assert_raise(::Logging::Config::YamlConfigurator::Error) {
        ::Logging::Config::YamlConfigurator.new(io, :meh)
      }
    end

  end  # class TestYamlConfigurator

end  # module TestConfig
end  # module TestLogging

