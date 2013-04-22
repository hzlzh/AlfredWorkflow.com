
module Logging::Appenders

  # The Buffering module is used to implement buffering of the log messages
  # in a given appender. The size of the buffer can be specified, and the
  # buffer can be configured to auto-flush at a given threshold. The
  # threshold can be a single message or a very large number of messages.
  #
  # Log messages of a certain level can cause the buffer to be flushed
  # immediately. If an error occurs, all previous messages and the error
  # message will be written immediately to the logging destination if the
  # buffer is configured to do so.
  #
  module Buffering

    # Default buffer size
    #
    DEFAULT_BUFFER_SIZE = 500;

    # The buffer holding the log messages
    #
    attr_reader :buffer

    # The auto-flushing setting. When the buffer reaches this size, all
    # messages will be be flushed automatically.
    #
    attr_reader :auto_flushing

    # When set, the buffer will be flushed at regular intervals defined by the
    # flush_period.
    #
    attr_reader :flush_period

    # Setup the message buffer and other variables for automatically and
    # periodically flushing the buffer.
    #
    def initialize( *args, &block )
      @buffer = []
      @immediate = []
      @auto_flushing = 1
      @flush_period = @periodic_flusher = nil

      super(*args, &block)
    end

    # Close the message buffer by flushing all log events to the appender. If a
    # periodic flusher thread is running, shut it down and allow it to exit.
    #
    def close( *args )
      flush

      if @periodic_flusher
        @periodic_flusher.stop
        @periodic_flusher = nil
        Thread.pass
      end

      super(*args)
    end

    # Reopen the connection to the underlying logging destination. In addition
    # if the appender is configured for periodic flushing, then the flushing
    # thread will be stopped and restarted.
    #
    def reopen
      _setup_periodic_flusher
      super
    end

    # Call +flush+ to force an appender to write out any buffered log events.
    # Similar to IO#flush, so use in a similar fashion.
    #
    def flush
      return self if @buffer.empty?

      str = nil
      sync {
        str = @buffer.join
        @buffer.clear
      }

      canonical_write str unless str.empty?
      self
    end

    # Configure the levels that will trigger an immediate flush of the
    # logging buffer. When a log event of the given level is seen, the
    # buffer will be flushed immediately. Only the levels explicitly given
    # in this assignment will flush the buffer; if an "error" message is
    # configured to immediately flush the buffer, a "fatal" message will not
    # even though it is a higher level. Both must be explicitly passed to
    # this assignment.
    #
    # You can pass in a single level name or number, an array of level
    # names or numbers, or a string containing a comma separated list of level
    # names or numbers.
    #
    #   immediate_at = :error
    #   immediate_at = [:error, :fatal]
    #   immediate_at = "warn, error"
    #
    def immediate_at=( level )
      @immediate.clear

      # get the immediate levels -- no buffering occurs at these levels, and
      # a log message is written to the logging destination immediately
      immediate_at =
        case level
        when String; level.split(',').map {|x| x.strip}
        when Array; level
        else Array(level) end

      immediate_at.each do |lvl|
        num = ::Logging.level_num(lvl)
        next if num.nil?
        @immediate[num] = true
      end
    end

    # Configure the auto-flushing threshold. Auto-flushing is used to flush
    # the contents of the logging buffer to the logging destination
    # automatically when the buffer reaches a certain threshold.
    #
    # By default, the auto-flushing will be configured to flush after each
    # log message.
    #
    # The allowed settings are as follows:
    #
    #   N      : flush after every N messages (N is an integer)
    #   true   : flush after each log message
    #   false  OR
    #   nil    OR
    #   0      : only flush when the buffer is full (500 messages)
    #
    # If the default buffer size of 500 is too small, then you can manually
    # configure it to be as large as you want. This will consume more memory.
    #
    #   auto_flushing = 42_000
    #
    def auto_flushing=( period )
      @auto_flushing =
        case period
        when true;             1
        when false, nil, 0;    DEFAULT_BUFFER_SIZE
        when Integer;          period
        when String;           Integer(period)
        else
          raise ArgumentError,
                "unrecognized auto_flushing period: #{period.inspect}"
        end

      if @auto_flushing <= 0
        raise ArgumentError,
          "auto_flushing period must be greater than zero: #{period.inspect}"
      end

      @auto_flushing = DEFAULT_BUFFER_SIZE if @flush_period and @auto_flushing <= 1
    end

    # Configure periodic flushing of the message buffer. Periodic flushing is
    # used to flush the contents of the logging buffer at some regular
    # interval. Periodic flushing is disabled by default.
    #
    # When enabling periodic flushing the flush period should be set using one
    # of the following formats: "HH:MM:SS" or seconds as an numeric or string.
    #
    #   "01:00:00"  : every hour
    #   "00:05:00"  : every 5 minutes
    #   "00:00:30"  : every 30 seconds
    #   60          : every 60 seconds (1 minute)
    #   "120"       : every 120 seconds (2 minutes)
    #
    # For the periodic flusher to work properly, the auto-flushing threshold
    # will be set to the default value of 500. The auto-flushing threshold can
    # be changed, but it must be greater than 1.
    #
    # To disable the periodic flusher simply set the flush period to +nil+.
    # The auto-flushing threshold will not be changed; it must be disabled
    # manually if so desired.
    #
    def flush_period=( period )
      period =
        case period
        when Integer, Float, nil; period
        when String;
          num = _parse_hours_minutes_seconds(period) || _parse_numeric(period)
          num = ArgumentError.new("unrecognized flush period: #{period.inspect}") if num.nil?
          num
        else ArgumentError.new("unrecognized flush period: #{period.inspect}") end

      raise period if Exception === period
      @flush_period = period

      _setup_periodic_flusher
    end

  protected

    # Configure the buffering using the arguments found in the give options
    # hash. This method must be called in order to use the message buffer.
    # The supported options are "immediate_at" and "auto_flushing". Please
    # refer to the documentation for those methods to see the allowed
    # options.
    #
    def configure_buffering( opts )
      ::Logging.init unless ::Logging.initialized?

      self.immediate_at = opts.getopt(:immediate_at, '')
      self.auto_flushing = opts.getopt(:auto_flushing, true)
      self.flush_period = opts.getopt(:flush_period, nil)
    end

    # Returns true if the _event_ level matches one of the configured
    # immediate logging levels. Otherwise returns false.
    #
    def immediate?( event )
      return false unless event.respond_to? :level
      @immediate[event.level]
    end


  private

    # call-seq:
    #    write( event )
    #
    # Writes the given _event_ to the logging destination. The _event_ can
    # be either a LogEvent or a String. If a LogEvent, then it will be
    # formatted using the layout given to the appender when it was created.
    #
    # The _event_ will be formatted and then buffered until the
    # "auto_flushing" level has been reached. At this time the canonical_write
    # method will be used to log all events stored in the buffer.
    #
    def write( event )
      str = event.instance_of?(::Logging::LogEvent) ?
            layout.format(event) : event.to_s
      return if str.empty?

      if @auto_flushing == 1
        canonical_write(str)
      else
        sync {
          str = str.force_encoding(encoding) if encoding and str.encoding != encoding
          @buffer << str
        }
        @periodic_flusher.signal if @periodic_flusher
        flush if @buffer.length >= @auto_flushing || immediate?(event)
      end

      self
    end

    # Attempt to parse an hours/minutes/seconds value from the string and return
    # an integer number of seconds.
    #
    #   _parse_hours_minutes_seconds("14:12:42")  #=> 51162
    #   _parse_hours_minutes_seconds("foo")       #=> nil
    #
    def _parse_hours_minutes_seconds( str )
      m = %r/^\s*(\d{2,}):(\d{2}):(\d{2}(?:\.\d+)?)\s*$/.match(str)
      return if m.nil?

      (3600 * m[1].to_i) + (60 * m[2].to_i) + (m[3].to_f)
    end

    # Convert the string into a numeric value. If the string does not
    # represent a valid Integer or Float then +nil+ is returned.
    #
    #   _parse_numeric("10")   #=> 10
    #   _parse_numeric("1.0")  #=> 1.0
    #   _parse_numeric("foo")  #=> nil
    #
    def _parse_numeric( str )
      Integer(str) rescue (Float(str) rescue nil)
    end

    # Using the flush_period, create a new PeriodicFlusher attached to this
    # appender. If the flush_period is nil, then no action will be taken. If a
    # PeriodicFlusher already exists, it will be stopped and a new one will be
    # created.
    #
    def _setup_periodic_flusher
      # stop and remove any existing periodic flusher instance
      if @periodic_flusher
        @periodic_flusher.stop
        @periodic_flusher = nil
        Thread.pass
      end

      # create a new periodic flusher if we have a valid flush period
      if @flush_period
        @auto_flushing = DEFAULT_BUFFER_SIZE unless @auto_flushing > 1
        @periodic_flusher = PeriodicFlusher.new(self, @flush_period)
        @periodic_flusher.start
      end
    end

    # :stopdoc:

    # The PeriodicFlusher contains an internal run loop that will periodically
    # wake up and flush any log events contained in the message buffer of the
    # owning appender instance. The PeriodicFlusher relies on a _signal_ from
    # the appender in order to wakeup and perform the flush on the appender.
    #
    class PeriodicFlusher

      # Create a new PeriodicFlusher instance that will call the +flush+
      # method on the given _appender_. The +flush+ method will be called
      # every _period_ seconds, but only when the message buffer is non-empty.
      #
      def initialize( appender, period )
        @appender = appender
        @period = period

        @mutex = Mutex.new
        @cv = ConditionVariable.new
        @thread = nil
        @waiting = nil
        @signaled = false
      end

      # Start the periodic flusher's internal run loop.
      #
      def start
        return if @thread

        @thread = Thread.new { loop {
          begin
            break if Thread.current[:stop]
            _wait_for_signal
            sleep @period unless Thread.current[:stop]
            @appender.flush
          rescue => err
            ::Logging.log_internal {"PeriodicFlusher for appender #{@appender.inspect} encountered an error"}
            ::Logging.log_internal(-2) {err}
          end
        }; @thread = nil }

        self
      end

      # Stop the periodic flusher's internal run loop.
      #
      def stop
        return if @thread.nil?
        @thread[:stop] = true
        signal if waiting?
        self
      end

      # Signal the periodic flusher. This will wake up the run loop if it is
      # currently waiting for something to do. If the signal method is never
      # called, the periodic flusher will never perform the flush action on
      # the appender.
      #
      def signal
        return if Thread.current == @thread   # don't signal ourselves
        return if @signaled                   # don't need to signal again

        @mutex.synchronize {
          @signaled = true
          @cv.signal
        }
        self
      end

      # Returns +true+ if the flusher is waiting for a signal. Returns +false+
      # if the flusher is somewhere in the processing loop.
      #
      def waiting?
        @waiting
      end

    private

      def _wait_for_signal
        @mutex.synchronize {
          begin
            # wait on the condition variable only if we have NOT been signaled
            unless @signaled
              @waiting = true
              @cv.wait(@mutex)
              @waiting = false
            end
          ensure
            @signaled = false
          end
        }
      ensure
        @waiting = false
      end
    end  # class PeriodicFlusher
    # :startdoc:

  end  # Buffering
end  # Logging::Appenders

