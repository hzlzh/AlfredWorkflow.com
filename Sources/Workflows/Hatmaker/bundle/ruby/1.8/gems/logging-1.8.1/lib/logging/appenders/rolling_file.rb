
module Logging::Appenders

  # Accessor / Factory for the RollingFile appender.
  #
  def self.rolling_file( *args )
    return ::Logging::Appenders::RollingFile if args.empty?
    ::Logging::Appenders::RollingFile.new(*args)
  end

  # An appender that writes to a file and ensures that the file size or age
  # never exceeds some user specified level.
  #
  # The goal of this class is to write log messages to a file. When the file
  # age or size exceeds a given limit then the log file is copied and then
  # truncated. The name of the copy indicates it is an older log file.
  #
  # The name of the log file is changed by inserting the age of the log file
  # (as a single number) between the log file name and the extension. If the
  # file has no extension then the number is appended to the filename. Here
  # is a simple example:
  #
  #    /var/log/ruby.log   =>   /var/log/ruby.1.log
  #
  # New log messages will continue to be appended to the same log file
  # (<tt>/var/log/ruby.log</tt> in our example above). The age number for all
  # older log files is incremented when the log file is rolled. The number of
  # older log files to keep can be given, otherwise all the log files are
  # kept.
  #
  # The actual process of rolling all the log file names can be expensive if
  # there are many, many older log files to process.
  #
  # If you do not wish to use numbered files when rolling, you can specify the
  # :roll_by option as 'date'. This will use a date/time stamp to
  # differentiate the older files from one another. If you configure your
  # rolling file appender to roll daily and ignore the file size:
  #
  #    /var/log/ruby.log   =>   /var/log/ruby.20091225.log
  #
  # Where the date is expressed as <tt>%Y%m%d</tt> in the Time#strftime format.
  #
  # NOTE: this class is not safe to use when log messages are written to files
  # on NFS mounts or other remote file system. It should only be used for log
  # files on the local file system. The exception to this is when a single
  # process is writing to the log file; remote file systems are safe to
  # use in this case but still not recommended.
  #
  class RollingFile < ::Logging::Appenders::IO

    # call-seq:
    #    RollingFile.new( name, opts )
    #
    # Creates a new Rolling File Appender. The _name_ is the unique Appender
    # name used to retrieve this appender from the Appender hash. The only
    # required option is the filename to use for creating log files.
    #
    #  [:filename]  The base filename to use when constructing new log
    #               filenames.
    #
    # The following options are optional:
    #
    #  [:layout]    The Layout that will be used by this appender. The Basic
    #               layout will be used if none is given.
    #  [:truncate]  When set to true any existing log files will be rolled
    #               immediately and a new, empty log file will be created.
    #  [:size]      The maximum allowed size (in bytes) of a log file before
    #               it is rolled.
    #  [:age]       The maximum age (in seconds) of a log file before it is
    #               rolled. The age can also be given as 'daily', 'weekly',
    #               or 'monthly'.
    #  [:keep]      The number of rolled log files to keep.
    #  [:roll_by]   How to name the rolled log files. This can be 'number' or
    #               'date'.
    #
    def initialize( name, opts = {} )
      # raise an error if a filename was not given
      @fn = opts.getopt(:filename, name)
      raise ArgumentError, 'no filename was given' if @fn.nil?

      @fn = ::File.expand_path(@fn)
      @fn_copy = @fn + '._copy_'
      ::Logging::Appenders::File.assert_valid_logfile(@fn)

      # grab our options
      @size = opts.getopt(:size, :as => Integer)

      code = 'def sufficiently_aged?() false end'
      @age_fn = @fn + '.age'
      @age_fn_mtime = nil

      case @age = opts.getopt(:age)
      when 'daily'
        code = <<-CODE
        def sufficiently_aged?
          @age_fn_mtime ||= ::File.mtime(@age_fn)
          now = Time.now
          if (now.day != @age_fn_mtime.day) or (now - @age_fn_mtime) > 86400
            return true
          end
          false
        end
        CODE
      when 'weekly'
        code = <<-CODE
        def sufficiently_aged?
          @age_fn_mtime ||= ::File.mtime(@age_fn)
          if (Time.now - @age_fn_mtime) > 604800
            return true
          end
          false
        end
        CODE
      when 'monthly'
        code = <<-CODE
        def sufficiently_aged?
          @age_fn_mtime ||= ::File.mtime(@age_fn)
          now = Time.now
          if (now.month != @age_fn_mtime.month) or (now - @age_fn_mtime) > 2678400
            return true
          end
          false
        end
        CODE
      when Integer, String
        @age = Integer(@age)
        code = <<-CODE
        def sufficiently_aged?
          @age_fn_mtime ||= ::File.mtime(@age_fn)
          if (Time.now - @age_fn_mtime) > @age
            return true
          end
          false
        end
        CODE
      end

      FileUtils.touch(@age_fn) if @age and !test(?f, @age_fn)

      meta = class << self; self end
      meta.class_eval code, __FILE__, __LINE__

      # we are opening the file in read/write mode so that a shared lock can
      # be used on the file descriptor => http://pubs.opengroup.org/onlinepubs/009695399/functions/fcntl.html
      @mode = encoding ? "a+:#{encoding}" : 'a+'
      super(name, ::File.new(@fn, @mode), opts)

      # setup the file roller
      @roller =
          case opts.getopt(:roll_by)
          when 'number'; NumberedRoller.new(@fn, opts)
          when 'date'; DateRoller.new(@fn, opts)
          else
            (@age and !@size) ?
                DateRoller.new(@fn, opts) :
                NumberedRoller.new(@fn, opts)
          end

      # if the truncate flag was set to true, then roll
      roll_now = opts.getopt(:truncate, false)
      if roll_now
        copy_truncate
        @roller.roll_files
      end
    end

    # Returns the path to the logfile.
    #
    def filename() @fn.dup end

    # Reopen the connection to the underlying logging destination. If the
    # connection is currently closed then it will be opened. If the connection
    # is currently open then it will be closed and immediately opened.
    #
    def reopen
      @mutex.synchronize {
        if defined? @io and @io
          flush
          @io.close rescue nil
        end
        @io = ::File.new(@fn, @mode)
      }
      super
      self
    end


  private

    # Write the given _event_ to the log file. The log file will be rolled
    # if the maximum file size is exceeded or if the file is older than the
    # maximum age.
    #
    def canonical_write( str )
      return self if @io.nil?

      str = str.force_encoding(encoding) if encoding and str.encoding != encoding
      @io.flock_sh { @io.syswrite str }

      if roll_required?
        @io.flock? {
          @age_fn_mtime = nil
          copy_truncate if roll_required?
        }
        @roller.roll_files
      end
      self
    rescue StandardError => err
      self.level = :off
      ::Logging.log_internal {"appender #{name.inspect} has been disabled"}
      ::Logging.log_internal(-2) {err}
    end

    # Returns +true+ if the log file needs to be rolled.
    #
    def roll_required?
      return false if ::File.exist?(@fn_copy) and (Time.now - ::File.mtime(@fn_copy)) < 180

      # check if max size has been exceeded
      s = @size ? ::File.size(@fn) > @size : false

      # check if max age has been exceeded
      a = sufficiently_aged?

      return (s || a)
    end

    # Copy the contents of the logfile to another file. Truncate the logfile
    # to zero length. This method will set the roll flag so that all the
    # current logfiles will be rolled along with the copied file.
    #
    def copy_truncate
      return unless ::File.exist?(@fn)
      FileUtils.concat @fn, @fn_copy
      @io.truncate 0

      # touch the age file if needed
      if @age
        FileUtils.touch @age_fn
        @age_fn_mtime = nil
      end

      @roller.roll = true
    end


    # :stopdoc:
    class NumberedRoller
      attr_accessor :roll

      def initialize( fn, opts )
        # grab the information we need to properly roll files
        ext = ::File.extname(fn)
        bn = ::File.join(::File.dirname(fn), ::File.basename(fn, ext))
        @rgxp = %r/\.(\d+)#{Regexp.escape(ext)}\z/
        @glob = "#{bn}.*#{ext}"
        @logname_fmt = "#{bn}.%d#{ext}"
        @fn_copy = fn + '._copy_'
        @keep = opts.getopt(:keep, :as => Integer)
        @roll = false
      end

      def roll_files
        return unless @roll and ::File.exist?(@fn_copy)

        files = Dir.glob(@glob).find_all {|fn| @rgxp =~ fn}
        unless files.empty?
          # sort the files in reverse order based on their count number
          files = files.sort do |a,b|
                    a = Integer(@rgxp.match(a)[1])
                    b = Integer(@rgxp.match(b)[1])
                    b <=> a
                  end

          # for each file, roll its count number one higher
          files.each do |fn|
            cnt = Integer(@rgxp.match(fn)[1])
            if @keep and cnt >= @keep
              ::File.delete fn
              next
            end
            ::File.rename fn, sprintf(@logname_fmt, cnt+1)
          end
        end

        # finally rename the copied log file
        ::File.rename(@fn_copy, sprintf(@logname_fmt, 1))
      ensure
        @roll = false
      end
    end

    class DateRoller
      attr_accessor :roll

      def initialize( fn, opts )
        @fn_copy = fn + '._copy_'
        @roll = false
        @keep = opts.getopt(:keep, :as => Integer)

        ext = ::File.extname(fn)
        bn = ::File.join(::File.dirname(fn), ::File.basename(fn, ext))

        if @keep
          @rgxp = %r/\.(\d+)(-\d+)?#{Regexp.escape(ext)}\z/
          @glob = "#{bn}.*#{ext}"
        end

        if %w[daily weekly monthly].include?(opts.getopt(:age)) and !opts.getopt(:size)
          @logname_fmt = "#{bn}.%Y%m%d#{ext}"
        else
          @logname_fmt = "#{bn}.%Y%m%d-%H%M%S#{ext}"
        end
      end

      def roll_files
        return unless @roll and ::File.exist?(@fn_copy)

        # rename the copied log file
        ::File.rename(@fn_copy, Time.now.strftime(@logname_fmt))

        # prune old log files
        if @keep
          files = Dir.glob(@glob).find_all {|fn| @rgxp =~ fn}
          length = files.length
          if length > @keep
            files.sort {|a,b| b <=> a}.last(length-@keep).each {|fn| ::File.delete fn}
          end
        end
      ensure
        @roll = false
      end
    end
    # :startdoc:

  end  # RollingFile
end  # Logging::Appenders

