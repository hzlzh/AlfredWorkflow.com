
module Logging::Appenders

  # Accessor / Factory for the IO appender.
  #
  def self.io( *args )
    return ::Logging::Appenders::IO if args.empty?
    ::Logging::Appenders::IO.new(*args)
  end

  # This class provides an Appender that can write to any IO stream
  # configured for writing.
  #
  class IO < ::Logging::Appender
    include Buffering

    # The method that will be used to close the IO stream. Defaults to :close
    # but can be :close_read, :close_write or nil. When nil, the IO stream
    # will not be closed when the appender's close method is called.
    #
    attr_accessor :close_method

    # call-seq:
    #    IO.new( name, io )
    #    IO.new( name, io, :layout => layout )
    #
    # Creates a new IO Appender using the given name that will use the _io_
    # stream as the logging destination.
    #
    def initialize( name, io, opts = {} )
      unless io.respond_to? :syswrite
        raise TypeError, "expecting an IO object but got '#{io.class.name}'"
      end

      @io = io
      @io.sync = true if io.respond_to? :sync=    # syswrite complains if the IO stream is buffered
      @io.flush rescue nil                        # syswrite also complains if in unbuffered mode and buffer isn't empty
      @close_method = :close

      super(name, opts)
      configure_buffering(opts)
    end

    # call-seq:
    #    close( footer = true )
    #
    # Close the appender and writes the layout footer to the logging
    # destination if the _footer_ flag is set to +true+. Log events will
    # no longer be written to the logging destination after the appender
    # is closed.
    #
    def close( *args )
      return self if @io.nil?
      super

      io, @io = @io, nil
      unless [STDIN, STDERR, STDOUT].include?(io)
        io.send(@close_method) if @close_method and io.respond_to? @close_method
      end
    rescue IOError
    ensure
      return self
    end


  private

    # This method is called by the buffering code when messages need to be
    # written to the logging destination.
    #
    def canonical_write( str )
      return self if @io.nil?
      str = str.force_encoding(encoding) if encoding and str.encoding != encoding
      @io.syswrite str
      self
    rescue StandardError => err
      self.level = :off
      ::Logging.log_internal {"appender #{name.inspect} has been disabled"}
      ::Logging.log_internal(-2) {err}
    end

  end  # IO
end  # Logging::Appenders

