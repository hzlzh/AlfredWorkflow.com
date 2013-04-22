
module Logging

  # This class defines a logging event.
  #
  LogEvent = Struct.new( :logger, :level, :data, :time, :file, :line, :method ) {
    # :stopdoc:

    # Regular expression used to parse out caller information
    #
    # * $1 == filename
    # * $2 == line number
    # * $3 == method name (might be nil)
    CALLER_RGXP = %r/([-\.\/\(\)\w]+):(\d+)(?::in `(\w+)')?/o
    #CALLER_INDEX = 2
    CALLER_INDEX = ((defined? JRUBY_VERSION and JRUBY_VERSION > '1.6') or (defined? RUBY_ENGINE and RUBY_ENGINE[%r/^rbx/i])) ? 1 : 2
    # :startdoc:

    # call-seq:
    #    LogEvent.new( logger, level, [data], trace )
    #
    # Creates a new log event with the given _logger_ name, numeric _level_,
    # array of _data_ from the user to be logged, and boolean _trace_ flag.
    # If the _trace_ flag is set to +true+ then Kernel::caller will be
    # invoked to get the execution trace of the logging method.
    #
    def initialize( logger, level, data, trace )
      f = l = m = ''

      if trace
        stack = Kernel.caller[CALLER_INDEX]
        return if stack.nil?

        match = CALLER_RGXP.match(stack)
        f = match[1]
        l = Integer(match[2])
        m = match[3] unless match[3].nil?
      end

      super(logger, level, data, Time.now, f, l, m)
    end
  }
end  # module Logging

