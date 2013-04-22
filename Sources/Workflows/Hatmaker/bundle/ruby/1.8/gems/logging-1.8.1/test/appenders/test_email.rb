
require File.expand_path('../setup', File.dirname(__FILE__))
require 'flexmock'

module TestLogging
module TestAppenders

  class TestEmail < Test::Unit::TestCase
    include FlexMock::TestCase
    include LoggingTestCase

    def setup
      super

      flexmock(Net::SMTP).new_instances do |m|
        m.should_receive(:start).at_least.once.with(
            'test.logging', 'test', 'test', :plain, Proc).and_yield(m)
        m.should_receive(:sendmail).at_least.once.with(String, 'me', ['you'])
      end

      @appender = Logging.appenders.email('email',
          'from' => 'me', 'to' => 'you',
          :buffer_size => '3', :immediate_at => 'error, fatal',
          :domain => 'test.logging', :user_name => 'test', :password => 'test'
      )
      @levels = Logging::LEVELS
    end

    def test_initialize
      assert_raise(ArgumentError, 'Must specify from address') {
        Logging.appenders.email('email')
      }
      assert_raise(ArgumentError, 'Must specify to address') {
        Logging.appenders.email('email', :from => 'me')
      }
      assert_nothing_raised {
        Logging.appenders.email('email', :from => 'me', :to => 'you')
      }

      appender = Logging.appenders.email('email',
          'from' => 'me', 'to' => 'you'
      )

      assert_equal(100, appender.auto_flushing)
      assert_equal([], appender.instance_variable_get(:@immediate))
      assert_equal('localhost', appender.address)
      assert_equal(25, appender.port)

      domain = ENV['HOSTNAME'] || 'localhost.localdomain'
      assert_equal(domain, appender.domain)
      assert_equal(nil, appender.user_name)
      assert_equal(:plain, appender.authentication)
      assert_equal("Message from #{$0}", appender.subject)

      appender = Logging.appenders.email('email',
          'from' => 'lbrinn@gmail.com', 'to' => 'everyone',
          :buffsize => '1000', :immediate_at => 'error, fatal',
          :address => 'smtp.google.com', :port => '443',
          :domain => 'google.com', :user_name => 'lbrinn',
          :password => '1234', :authentication => 'plain', :enable_starttls_auto => true,
          :subject => "I'm rich and you're not"
      )

      assert_equal('lbrinn@gmail.com', appender.instance_variable_get(:@from))
      assert_equal(['everyone'], appender.instance_variable_get(:@to))
      assert_equal(1000, appender.auto_flushing)
      assert_equal('1234', appender.password)
      assert_equal([nil, nil, nil, true, true],
                   appender.instance_variable_get(:@immediate))
      assert_equal('smtp.google.com', appender.address)
      assert_equal(443, appender.port)
      assert_equal('google.com', appender.domain)
      assert_equal('lbrinn', appender.user_name)
      assert_equal(:plain, appender.authentication)
      assert(appender.enable_starttls_auto)
      assert_equal("I'm rich and you're not", appender.subject)

      appender = Logging.appenders.email('email',
          'from' => 'me', 'to' => 'you', :auto_flushing => 42
      )
      assert_equal(42, appender.auto_flushing)
    end

    def test_append
      # with auto_flushing enabled, mail will be sent each time a log event
      # occurs
      @appender.auto_flushing = true
      event = Logging::LogEvent.new('TestLogger', @levels['warn'],
                                    [1, 2, 3, 4], false)
      @appender.append event
      assert_not_equal(@levels.length, @appender.level)
      assert_equal(0, @appender.buffer.length)

      # increase the buffer size and log a few events
      @appender.auto_flushing = 3
      @appender.append event
      @appender.append event
      assert_equal(2, @appender.buffer.length)

      @appender.append event
      assert_not_equal(@levels.length, @appender.level)
      assert_equal(0, @appender.buffer.length)

      # error and fatal messages should be send immediately (no buffering)
      error = Logging::LogEvent.new('ErrLogger', @levels['error'],
                                    'error message', false)
      fatal = Logging::LogEvent.new('FatalLogger', @levels['fatal'],
                                    'fatal message', false)

      @appender.append event
      @appender.append fatal
      assert_not_equal(@levels.length, @appender.level)
      assert_equal(0, @appender.buffer.length)

      @appender.append error
      assert_not_equal(@levels.length, @appender.level)
      assert_equal(0, @appender.buffer.length)

      @appender.append event
      assert_equal(1, @appender.buffer.length)
    end

    def test_concat
      # with auto_flushing enabled, mail will be sent each time a log event
      # occurs
      @appender.auto_flushing = true
      @appender << 'test message'
      assert_not_equal(@levels.length, @appender.level)
      assert_equal(0, @appender.buffer.length)

      # increase the buffer size and log a few events
      @appender.auto_flushing = 3
      @appender << 'another test message'
      @appender << 'a second test message'
      assert_equal(2, @appender.buffer.length)

      @appender << 'a third test message'
      assert_not_equal(@levels.length, @appender.level)
      assert_equal(0, @appender.buffer.length)
    end

    def test_flush
      event = Logging::LogEvent.new('TestLogger', @levels['info'],
                                    [1, 2, 3, 4], false)
      @appender.append event
      @appender << 'test message'
      assert_equal(2, @appender.buffer.length)

      @appender.flush
      assert_not_equal(@levels.length, @appender.level)
      assert_equal(0, @appender.buffer.length)
    end

    def test_close
      event = Logging::LogEvent.new('TestLogger', @levels['info'],
                                    [1, 2, 3, 4], false)
      @appender.append event
      @appender << 'test message'
      assert_equal(2, @appender.buffer.length)

      @appender.close
      assert_not_equal(@levels.length, @appender.level)
      assert_equal(0, @appender.buffer.length)
      assert(@appender.closed?)
    end

  end  # class TestEmail
end  # module TestLogging
end  # module TestAppenders

