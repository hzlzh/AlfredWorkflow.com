
require File.expand_path('../setup', File.dirname(__FILE__))

module TestLogging
module TestAppenders

  class TestPeriodicFlushing < Test::Unit::TestCase
    include LoggingTestCase

    def setup
      super
      @appender = Logging.appenders.string_io(
        'test_appender', :flush_period => 2
      )
      @appender.clear
      @sio = @appender.sio
      @levels = Logging::LEVELS
      begin readline rescue EOFError end
      Thread.pass  # give the flusher thread a moment to start
    end

    def teardown
      @appender.close
      @appender = nil
      super
    end

    def test_flush_period_set
      assert_equal 2, @appender.flush_period
      assert_equal Logging::Appenders::Buffering::DEFAULT_BUFFER_SIZE, @appender.auto_flushing

      @appender.flush_period = '01:30:45'
      assert_equal 5445, @appender.flush_period

      @appender.flush_period = '245'
      assert_equal 245, @appender.flush_period

      @appender.auto_flushing = true
      assert_equal Logging::Appenders::Buffering::DEFAULT_BUFFER_SIZE, @appender.auto_flushing

      @appender.auto_flushing = 200
      assert_equal 200, @appender.auto_flushing
    end

    def test_periodic_flusher_running
      flusher = @appender.instance_variable_get(:@periodic_flusher)
      assert_instance_of Logging::Appenders::Buffering::PeriodicFlusher, flusher

      sleep 0.250  # give the flusher thread another moment to start
      assert flusher.waiting?, 'the periodic flusher should be waiting for a signal'
    end

    def test_append
      event = Logging::LogEvent.new('TestLogger', @levels['warn'],
                                    [1, 2, 3, 4], false)
      @appender.append event
      @appender.append event
      event.level = @levels['debug']
      event.data = 'the big log message'
      @appender.append event

      assert_nil(readline)
      sleep 3

      assert_equal " WARN  TestLogger : <Array> #{[1, 2, 3, 4]}\n", readline
      assert_equal " WARN  TestLogger : <Array> #{[1, 2, 3, 4]}\n", readline
      assert_equal "DEBUG  TestLogger : the big log message\n", readline
      assert_nil(readline)

      @appender.close
      assert_raise(RuntimeError) {@appender.append event}
    end

    def test_flush_on_close
      assert_equal false, @sio.closed?
      assert_equal false, @appender.closed?

      event = Logging::LogEvent.new('TestLogger', @levels['warn'],
                                    [1, 2, 3, 4], false)

      @appender.flush_period = "24:00:00"
      @appender.append event
      event.level = @levels['debug']
      event.data = 'the big log message'
      @appender.append event

      assert_nil(readline)

      @appender.close_method = :close_write
      @appender.close
      assert_equal false, @sio.closed?
      assert_equal true, @appender.closed?

      assert_equal " WARN  TestLogger : <Array> #{[1, 2, 3, 4]}\n", readline
      assert_equal "DEBUG  TestLogger : the big log message\n", readline
      assert_nil(readline)

      @sio.close
      assert_equal true, @sio.closed?
    end

    def test_auto_flushing
      @appender.auto_flushing = 3

      event = Logging::LogEvent.new('TestLogger', @levels['warn'],
                                    [1, 2, 3, 4], false)

      @appender.append event
      @appender.append event
      event.level = @levels['debug']
      event.data = 'the big log message'
      @appender.append event
      event.level = @levels['info']
      event.data = 'just FYI'
      @appender.append event
      event.level = @levels['warn']
      event.data = 'this is your last warning!'
      @appender.append event

      assert_equal " WARN  TestLogger : <Array> #{[1, 2, 3, 4]}\n", readline
      assert_equal " WARN  TestLogger : <Array> #{[1, 2, 3, 4]}\n", readline
      assert_equal "DEBUG  TestLogger : the big log message\n", readline

      assert_nil(readline)
      sleep 3

      assert_equal " INFO  TestLogger : just FYI\n", readline
      assert_equal " WARN  TestLogger : this is your last warning!\n", readline
      assert_nil(readline)
    end

  private
    def readline
      @appender.readline
    end

  end  # class TestPeriodicFlushing

end  # module TestAppenders
end  # module TestLogging

