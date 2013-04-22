
require File.expand_path('../setup', File.dirname(__FILE__))
require 'flexmock'

module TestLogging
module TestAppenders

  class TestGrowl < Test::Unit::TestCase
    include FlexMock::TestCase
    include LoggingTestCase

    def setup
      super

      @appender = Logging.appenders.growl('growl',
          :coalesce => true, :separator => "\000",
          :layout => Logging.layouts.pattern(:pattern => "%5l - Test\000%m")
      )
      @appender.level = :all
      @growl = @appender.instance_variable_get(:@growl).dup
      @levels = Logging::LEVELS
    end

    def test_initialize
      assert_equal('growlnotify -w -n "growl" -t "%s" -m "%s" -p %d &', @growl)
      assert_equal(true, @appender.instance_variable_get(:@coalesce))
      assert_equal("\000", @appender.instance_variable_get(:@title_sep))
    end

    def test_append
      info = Logging::LogEvent.new('TestLogger', @levels['info'],
                                   'info message', false)
      warn = Logging::LogEvent.new('TestLogger', @levels['warn'],
                                   'warning message', false)

      flexmock(@appender).should_receive(:system => true).once.with(
          @growl % ['WARN - Test', "warning message\nwarning message\nwarning message", 0])

      flexmock(@appender).should_receive(:system => true).once.with(
          @growl % ['INFO - Test', "info message\ninfo message", -1])

      flexmock(@appender).should_receive(:system => true).once.with(
          @growl % ['WARN - Test', "warning message", 0])

      @appender.append warn
      @appender.append warn
      @appender.append warn
      @appender.append info
      @appender.append info
      @appender.append warn
      ensure_queue_is_empty
    end

    def test_append_without_coalescing
      @appender.instance_variable_set(:@coalesce, false)
      event = Logging::LogEvent.new('TestLogger', @levels['warn'],
                                    'warning message', false)

      flexmock(@appender).should_receive(:system => true).twice.with(
          @growl % ['WARN - Test', 'warning message', 0])

      @appender.append event
      @appender.append event
    end

    def test_concat
      flexmock(@appender).should_receive(:system => true).once.with(
          @growl % ['', "first message\nsecond message\nthird message", 0])

      @appender << 'first message'
      @appender << 'second message'
      @appender << 'third message'
      ensure_queue_is_empty
    end

    def test_concat_without_coalescing
      @appender.instance_variable_set(:@coalesce, false)

      flexmock(@appender).should_receive(:system => true).twice.with(
          @growl % ['', 'concat message', 0])

      @appender << 'concat message'
      @appender << 'concat message'
    end

    def test_map_eq
      get_map = lambda {@appender.instance_variable_get(:@map)}
      assert_equal([-2,-1,0,1,2], get_map.call)

      @appender.map = {
        'fatal' => '0',
        :error => -2,
        :warn => '2',
        'INFO' => 1,
        'Debug' => -1
      }
      assert_equal([-1,1,2,-2,0], get_map.call)

      assert_raise(ArgumentError) do
        @appender.map = {:fatal => 'not a number', :error => 2}
      end

      assert_raise(ArgumentError) do
        @appender.map = {:fatal => -3, :error => 3}
      end
    end

    def test_disabling
      @appender.instance_variable_set(:@coalesce, false)
      event = Logging::LogEvent.new('TestLogger', @levels['warn'],
                                    'warning message', false)

      flexmock(@appender).should_receive(:system => false).once.with(
          @growl % ['WARN - Test', 'warning message', 0])

      assert_equal 0, @appender.level
      @appender.append event
      assert_equal 5, @appender.level
      @appender.append event
      @appender.append event
    end

  private

    def ensure_queue_is_empty
      start = Time.now

      queue = @appender.instance_variable_get :@c_queue
      sleep 0.2 until queue.empty? or (Time.now - start > 10)

      thread = @appender.instance_variable_get :@c_thread
      sleep 0.2 until thread.status == 'sleep' or (Time.now - start > 10)
    end

  end  # class TestGrowl
end  # module TestLogging
end  # module TestAppenders

