
require File.expand_path('../setup', __FILE__)

module TestLogging

  class TestLogging < Test::Unit::TestCase
    include LoggingTestCase

    def setup
      super
      @levels = ::Logging::LEVELS
      @lnames = ::Logging::LNAMES

      @fn = File.join(TMP, 'test.log')
      @glob = File.join(TMP, '*.log')
    end

    def test_backtrace
      assert_equal true, ::Logging.backtrace

      assert_equal false, ::Logging.backtrace('off')
      assert_equal false, ::Logging.backtrace

      assert_equal true, ::Logging.backtrace('on')
      assert_equal true, ::Logging.backtrace

      assert_equal false, ::Logging.backtrace(:off)
      assert_equal false, ::Logging.backtrace

      assert_equal true, ::Logging.backtrace(:on)
      assert_equal true, ::Logging.backtrace

      assert_equal false, ::Logging.backtrace(false)
      assert_equal false, ::Logging.backtrace

      assert_equal true, ::Logging.backtrace(true)
      assert_equal true, ::Logging.backtrace

      assert_raise(ArgumentError) {::Logging.backtrace 'foo'}
    end

    def test_configure
      assert_raise(ArgumentError) {::Logging.configure 'blah.txt'}

      ::Logging.configure 'data/logging.yaml'

      names = %w[DEB INF PRT WRN ERR FAT]
      assert_equal names, ::Logging::LNAMES
      assert_equal :inspect, ::Logging::OBJ_FORMAT
      assert_equal 3, ::Logging::Logger.root.level

      # verify the appenders
      h = ::Logging::Appenders.instance_variable_get :@appenders
      assert_equal ['logfile', 'stderr'], h.keys.sort

      # start with the File appender
      logfile = ::Logging::Appenders['logfile']
      assert_instance_of ::Logging::Appenders::File, logfile
      assert_equal 0, logfile.level
      assert_equal ::File.expand_path('tmp/temp.log'), logfile.instance_variable_get(:@fn)

      layout = logfile.layout
      assert_instance_of ::Logging::Layouts::Pattern, layout
      assert_equal '[%d] %l  %c : %m\\n', layout.pattern
      assert_equal 'to_s', layout.date_method
      assert_nil layout.date_pattern

      # and now the Stderr appender
      stderr = ::Logging::Appenders['stderr']
      assert_instance_of ::Logging::Appenders::Stderr, stderr
      assert_equal 0, stderr.level

      layout = stderr.layout
      assert_instance_of ::Logging::Layouts::Basic, layout

      # verify the loggers
      h = ::Logging::Repository.instance.instance_variable_get :@h
      assert_equal 4, h.length

      # mylogger
      mylogger = ::Logging::Logger['mylogger']
      assert_equal 0, mylogger.level
      assert_equal false, mylogger.additive
      assert_equal false, mylogger.trace

      appenders = mylogger.instance_variable_get :@appenders
      assert_equal 2, appenders.length
      assert_equal ['logfile', 'stderr'], appenders.map {|a| a.name}.sort

      # yourlogger
      yourlogger = ::Logging::Logger['yourlogger']
      assert_equal 1, yourlogger.level
      assert_equal true, yourlogger.additive
      assert_equal false, yourlogger.trace

      appenders = yourlogger.instance_variable_get :@appenders
      assert_equal 2, appenders.length
      assert_equal ['logfile', 'stderr'], appenders.map {|a| a.name}.sort
    end

    def test_logger
      assert_raise(TypeError) {::Logging.logger []}

      logger = ::Logging.logger STDOUT
      assert_match %r/\A-?\d+\z/, logger.name
      assert_same logger, ::Logging.logger(STDOUT)

      logger.close
      assert !STDOUT.closed?

      assert !File.exist?(@fn)
      fd = File.new @fn, 'w'
      logger = ::Logging.logger fd, 2, 100
      assert_equal @fn, logger.name
      logger.debug 'this is a debug message'
      logger.warn 'this is a warning message'
      logger.error 'and now we should have over 100 bytes of data ' +
                   'in the log file'
      logger.info 'but the log file should not roll since we provided ' +
                  'a file descriptor -- not a file name'
      logger.close
      assert fd.closed?
      assert File.exist?(@fn)
      assert_equal 1, Dir.glob(@glob).length

      FileUtils.rm_f @fn
      assert !File.exist?(@fn)
      logger = ::Logging.logger @fn, 2, 100
      assert File.exist?(@fn)
      assert_equal @fn, logger.name
      logger.debug 'this is a debug message'
      logger.warn 'this is a warning message'
      logger.error 'and now we should have over 100 bytes of data ' +
                   'in the log file'
      logger.info 'but the log file should not roll since we provided ' +
                  'a file descriptor -- not a file name'
      logger.close
      assert_equal 3, Dir.glob(@glob).length
    end

    def test_init_default
      assert_equal({}, @levels)
      assert_equal([], @lnames)
      assert_same false, ::Logging.initialized?

      ::Logging::Repository.instance

      assert_equal 5, @levels.length
      assert_equal 5, @lnames.length
      assert_equal 5, ::Logging::MAX_LEVEL_LENGTH

      assert_equal 0, @levels['debug']
      assert_equal 1, @levels['info']
      assert_equal 2, @levels['warn']
      assert_equal 3, @levels['error']
      assert_equal 4, @levels['fatal']

      assert_equal 'DEBUG', @lnames[0]
      assert_equal 'INFO',  @lnames[1]
      assert_equal 'WARN',  @lnames[2]
      assert_equal 'ERROR', @lnames[3]
      assert_equal 'FATAL', @lnames[4]
    end

    def test_init_special
      assert_equal({}, @levels)
      assert_equal([], @lnames)
      assert_same false, ::Logging.initialized?

      assert_raise(ArgumentError) {::Logging.init(1, 2, 3, 4)}

      ::Logging.init :one, 'two', :THREE, 'FoUr', :sIx

      assert_equal 5, @levels.length
      assert_equal 5, @lnames.length
      assert_equal 5, ::Logging::MAX_LEVEL_LENGTH

      assert_equal 0, @levels['one']
      assert_equal 1, @levels['two']
      assert_equal 2, @levels['three']
      assert_equal 3, @levels['four']
      assert_equal 4, @levels['six']

      assert_equal 'ONE',   @lnames[0]
      assert_equal 'TWO',   @lnames[1]
      assert_equal 'THREE', @lnames[2]
      assert_equal 'FOUR',  @lnames[3]
      assert_equal 'SIX',   @lnames[4]
    end

    def test_init_all_off
      assert_equal({}, @levels)
      assert_equal([], @lnames)
      assert_same false, ::Logging.initialized?

      ::Logging.init %w(a b all c off d)

      assert_equal 4, @levels.length
      assert_equal 4, @lnames.length
      assert_equal 3, ::Logging::MAX_LEVEL_LENGTH

      assert_equal 0, @levels['a']
      assert_equal 1, @levels['b']
      assert_equal 2, @levels['c']
      assert_equal 3, @levels['d']

      assert_equal 'A', @lnames[0]
      assert_equal 'B', @lnames[1]
      assert_equal 'C', @lnames[2]
      assert_equal 'D', @lnames[3]
    end

    def test_format_as
      assert_equal false, ::Logging.const_defined?('OBJ_FORMAT')

      assert_raises(ArgumentError) {::Logging.format_as 'bob'}
      assert_raises(ArgumentError) {::Logging.format_as String}
      assert_raises(ArgumentError) {::Logging.format_as :what?}

      remove_const = lambda do |const|
        ::Logging.class_eval {remove_const const if const_defined? const}
      end

      ::Logging.format_as :string
      assert ::Logging.const_defined?('OBJ_FORMAT')
      assert_equal :string, ::Logging::OBJ_FORMAT
      remove_const[:OBJ_FORMAT]

      ::Logging.format_as :inspect
      assert ::Logging.const_defined?('OBJ_FORMAT')
      assert_equal :inspect, ::Logging::OBJ_FORMAT
      remove_const[:OBJ_FORMAT]

      ::Logging.format_as :json
      assert ::Logging.const_defined?('OBJ_FORMAT')
      assert_equal :json, ::Logging::OBJ_FORMAT
      remove_const[:OBJ_FORMAT]

      ::Logging.format_as :yaml
      assert ::Logging.const_defined?('OBJ_FORMAT')
      assert_equal :yaml, ::Logging::OBJ_FORMAT
      remove_const[:OBJ_FORMAT]

      ::Logging.format_as 'string'
      assert ::Logging.const_defined?('OBJ_FORMAT')
      assert_equal :string, ::Logging::OBJ_FORMAT
      remove_const[:OBJ_FORMAT]

      ::Logging.format_as 'inspect'
      assert ::Logging.const_defined?('OBJ_FORMAT')
      assert_equal :inspect, ::Logging::OBJ_FORMAT
      remove_const[:OBJ_FORMAT]

      ::Logging.format_as 'yaml'
      assert ::Logging.const_defined?('OBJ_FORMAT')
      assert_equal :yaml, ::Logging::OBJ_FORMAT
      remove_const[:OBJ_FORMAT]
    end

    def test_path
      path = ::Logging.path(*%w[one two three])
      assert_match %r/one\/two\/three$/, path
    end

    def test_version
      assert_match %r/\d+\.\d+\.\d+/, ::Logging.version
    end

  end  # class TestLogging
end  # module TestLogging

