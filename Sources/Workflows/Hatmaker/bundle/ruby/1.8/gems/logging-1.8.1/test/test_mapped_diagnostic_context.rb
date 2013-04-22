
require File.expand_path('../setup', __FILE__)

module TestLogging

  class TestMappedDiagnosticContext < Test::Unit::TestCase
    include LoggingTestCase

    def test_key_value_access
      assert_nil Logging.mdc['foo']

      Logging.mdc['foo'] = 'bar'
      assert_equal 'bar', Logging.mdc[:foo]
      assert_same Logging.mdc['foo'], Logging.mdc[:foo]

      Logging.mdc.delete(:foo)
      assert_nil Logging.mdc['foo']
    end

    def test_clear
      Logging.mdc['foo'] = 'bar'
      Logging.mdc['baz'] = 'buz'

      assert_equal 'bar', Logging.mdc[:foo]
      assert_equal 'buz', Logging.mdc[:baz]

      Logging.mdc.clear

      assert_nil Logging.mdc['foo']
      assert_nil Logging.mdc['baz']
    end

    def test_thread_uniqueness
      Logging.mdc['foo'] = 'bar'
      Logging.mdc['baz'] = 'buz'

      t = Thread.new {
        sleep

        Logging.mdc.clear
        assert_nil Logging.mdc['foo']
        assert_nil Logging.mdc['baz']

        Logging.mdc['foo'] = 42
        assert_equal 42, Logging.mdc['foo']
      }

      Thread.pass until t.status == 'sleep'
      t.run
      t.join

      assert_equal 'bar', Logging.mdc['foo']
      assert_equal 'buz', Logging.mdc['baz']
    end

    def test_thread_inheritance
      Logging.mdc['foo'] = 'bar'
      Logging.mdc['baz'] = 'buz'

      t = Thread.new(Logging.mdc.context) { |context|
        sleep

        assert_not_equal context.object_id, Logging.mdc.context.object_id

        assert_equal 'bar', Logging.mdc['foo']
        assert_equal 'buz', Logging.mdc['baz']
        assert_nil Logging.mdc['unique']
      }

      Thread.pass until t.status == 'sleep'
      Logging.mdc['unique'] = 'value'

      t.run
      t.join
    end

  end  # class TestMappedDiagnosticContext
end  # module TestLogging
