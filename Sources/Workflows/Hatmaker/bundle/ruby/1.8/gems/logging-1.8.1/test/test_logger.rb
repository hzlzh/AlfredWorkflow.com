
require File.expand_path('setup', File.dirname(__FILE__))

module TestLogging

  class TestLogger < Test::Unit::TestCase
    include LoggingTestCase

    def test_initialize
      assert_nothing_raised {::Logging::Logger[:test]}
      assert_equal ::Logging::Logger[:test], ::Logging::Logger['test']
      assert_nothing_raised {::Logging::Logger.new(Object)}
    end

    def test_add
      root = ::Logging::Logger[:root]
      root.level = 'info'

      a1 = ::Logging::Appenders::StringIo.new 'a1'
      a2 = ::Logging::Appenders::StringIo.new 'a2'
      log = ::Logging::Logger.new 'A Logger'

      root.add_appenders a1
      assert_nil a1.readline
      assert_nil a2.readline

      log.add(0, 'this should NOT be logged')
      assert_nil a1.readline
      assert_nil a2.readline

      log.add(1, 'this should be logged')
      assert_equal " INFO  A Logger : this should be logged\n", a1.readline
      assert_nil a1.readline
      assert_nil a2.readline

      log.add(2,[1,2,3,4])
      assert_equal " WARN  A Logger : <Array> #{[1,2,3,4]}\n", a1.readline
      assert_nil a1.readline
      assert_nil a2.readline

      log.add_appenders a2
      log.add(3, 'an error has occurred')
      assert_equal "ERROR  A Logger : an error has occurred\n", a1.readline
      assert_equal "ERROR  A Logger : an error has occurred\n", a2.readline
      assert_nil a1.readline
      assert_nil a2.readline

      log.additive = false
      log.add(3, 'another error has occurred')
      assert_equal "ERROR  A Logger : another error has occurred\n", a2.readline
      assert_nil a1.readline
      assert_nil a2.readline

      log.add_appenders a1
      log.add(4, 'fatal exception')
      assert_equal "FATAL  A Logger : fatal exception\n", a1.readline
      assert_equal "FATAL  A Logger : fatal exception\n", a2.readline
      assert_nil a1.readline
      assert_nil a2.readline


      log.level = :warn
      log.add(2) do
        str = 'a string of data'
        str
      end
      assert_equal " WARN  A Logger : a string of data\n", a1.readline
      assert_equal " WARN  A Logger : a string of data\n", a2.readline
      assert_nil a1.readline
      assert_nil a2.readline

      log.add(1) do
        rb_raise(RuntimeError, "this block should not be executed")
      end
      assert_nil a1.readline
      assert_nil a2.readline
    end

    def test_add_appenders
      log = ::Logging::Logger.new 'A'

      appenders = lambda {log.instance_variable_get :@appenders}
      assert_equal [], appenders[]

      assert_raise(ArgumentError) {log.add_appenders Object.new}
      assert_raise(ArgumentError) {log.add_appenders 'not an appender'}

      a = ::Logging::Appender.new 'test_appender_1'
      b = ::Logging::Appender.new 'test_appender_2'
      c = ::Logging::Appender.new 'test_appender_3'

      log.add_appenders a
      assert_equal [a], appenders[]

      log.add_appenders a
      assert_equal [a], appenders[]

      log.add_appenders b
      assert_equal [a,b], appenders[]

      log.add_appenders c
      assert_equal [a,b,c], appenders[]

      log.add_appenders a, c
      assert_equal [a,b,c], appenders[]

      log.clear_appenders
      assert_equal [], appenders[]

      log.add_appenders a, c
      assert_equal [a,c], appenders[]
    end

    def test_additive
      root = ::Logging::Logger.new :root
      log  = ::Logging::Logger.new 'A'

      assert_raise(NoMethodError) {root.additive}
      assert_equal true, log.additive
    end

    def test_additive_eq
      root = ::Logging::Logger.new :root
      log  = ::Logging::Logger.new 'A'

      assert_raise(NoMethodError) {root.additive = false}
      assert_equal true, log.additive

      log.additive = false
      assert_equal false, log.additive

      log.additive = true
      assert_equal true, log.additive

      log.additive = 'false'
      assert_equal false, log.additive

      log.additive = 'true'
      assert_equal true, log.additive

      log.additive = nil
      assert_equal true, log.additive

      assert_raise(ArgumentError) {log.additive = Object}
    end

    def test_appenders_eq
      log = ::Logging::Logger.new '42'

      appenders = lambda {log.instance_variable_get :@appenders}
      assert_equal [], appenders[]

      assert_raise(ArgumentError) {log.appenders = Object.new}
      assert_raise(ArgumentError) {log.appenders = 'not an appender'}

      a = ::Logging::Appender.new 'test_appender_1'
      b = ::Logging::Appender.new 'test_appender_2'
      c = ::Logging::Appender.new 'test_appender_3'

      log.appenders = a, b, c
      assert_equal [a, b, c], appenders[]

      log.appenders = b
      assert_equal [b], appenders[]

      log.appenders = c, a, b
      assert_equal [c,a,b], appenders[]

      log.appenders = nil
      assert_equal [], appenders[]

      log.appenders = %w[test_appender_1 test_appender_3]
      assert_equal [a,c], appenders[]

      assert_raise(ArgumentError) {log.appenders = 'unknown'}
    end

    def test_class_aref
      root = ::Logging::Logger[:root]
      assert_same root, ::Logging::Logger[:root]

      a = []
      assert_same ::Logging::Logger['Array'], ::Logging::Logger[Array]
      assert_same ::Logging::Logger['Array'], ::Logging::Logger[a]

      assert_not_same ::Logging::Logger['Array'], ::Logging::Logger[:root]
      assert_not_same ::Logging::Logger['A'], ::Logging::Logger['A::B']
    end

    def test_class_root
      root = ::Logging::Logger[:root]
      assert_same root, ::Logging::Logger.root
    end

    def test_clear_appenders
      log  = ::Logging::Logger.new 'Elliott'

      appenders = lambda {log.instance_variable_get :@appenders}
      assert_equal [], appenders[]

      a = ::Logging::Appender.new 'test_appender_1'
      b = ::Logging::Appender.new 'test_appender_2'
      c = ::Logging::Appender.new 'test_appender_3'

      log.add_appenders a, b, c
      assert_equal [a,b,c], appenders[]

      log.clear_appenders
      assert_equal [], appenders[]
    end

    def test_concat
      a1 = ::Logging::Appenders::StringIo.new 'a1'
      a2 = ::Logging::Appenders::StringIo.new 'a2'
      log = ::Logging::Logger.new 'A'

      ::Logging::Logger[:root].add_appenders a1
      assert_nil a1.readline
      assert_nil a2.readline

      log << "this is line one of the log file\n"
      assert_equal "this is line one of the log file\n", a1.readline
      assert_nil a1.readline
      assert_nil a2.readline

      log << "this is line two of the log file\n"
      log << "this is line three of the log file\n"
      assert_equal "this is line two of the log file\n", a1.readline
      assert_equal "this is line three of the log file\n", a1.readline
      assert_nil a1.readline
      assert_nil a2.readline

      log.add_appenders a2
      log << "this is line four of the log file\n"
      assert_equal "this is line four of the log file\n", a1.readline
      assert_equal "this is line four of the log file\n", a2.readline
      assert_nil a1.readline
      assert_nil a2.readline

      log.additive = false
      log << "this is line five of the log file\n"
      assert_equal "this is line five of the log file\n", a2.readline
      assert_nil a1.readline
      assert_nil a2.readline

      log.add_appenders a1
      log << "this is line six of the log file\n"
      assert_equal "this is line six of the log file\n", a1.readline
      assert_equal "this is line six of the log file\n", a2.readline
      assert_nil a1.readline
      assert_nil a2.readline
    end

    def test_inspect
      root = ::Logging::Logger.new :root

      str = "<#{root.class.name}:0x%x name=\"#{root.name}\">" % root.object_id
      assert_equal str, root.inspect
    end

    def test_level
      root = ::Logging::Logger.new :root
      log  = ::Logging::Logger.new 'A'

      assert_equal 0, root.level
      assert_equal 0, log.level

      root.level = :warn
      assert_equal 2, root.level
      assert_equal 2, log.level

      log.level = nil
      assert_equal 2, root.level
      assert_equal 2, log.level

      log.level = :error
      assert_equal 2, root.level
      assert_equal 3, log.level
    end

    def test_level_eq
      root = ::Logging::Logger.new :root
      log  = ::Logging::Logger.new 'A'
      logb = ::Logging::Logger.new 'A::B'

      assert_equal 0, root.level
      assert_equal 0, log.level
      assert_equal 0, logb.level
      assert_equal true, root.debug?
      assert_equal true, log.debug?
      assert_equal true, logb.debug?

      assert_raise(ArgumentError) {root.level = -1}
      assert_raise(ArgumentError) {root.level =  6}
      assert_raise(ArgumentError) {root.level = Object}
      assert_raise(ArgumentError) {root.level = 'bob'}
      assert_raise(ArgumentError) {root.level = :wtf}

      root.level = 'INFO'
      assert_equal 1, root.level
      assert_equal 1, log.level
      assert_equal 1, logb.level
      assert_equal false, root.debug?
      assert_equal true,  root.info?
      assert_equal false, log.debug?
      assert_equal true , log.info?
      assert_equal false, logb.debug?
      assert_equal true , logb.info?

      root.level = :warn
      assert_equal 2, root.level
      assert_equal 2, log.level
      assert_equal 2, logb.level
      assert_equal false, root.info?
      assert_equal true,  root.warn?
      assert_equal false, log.info?
      assert_equal true , log.warn?
      assert_equal false, logb.info?
      assert_equal true , logb.warn?

      root.level = 'error'
      assert_equal 3, root.level
      assert_equal 3, log.level
      assert_equal 3, logb.level
      assert_equal false, root.warn?
      assert_equal true,  root.error?
      assert_equal false, log.warn?
      assert_equal true , log.error?
      assert_equal false, logb.warn?
      assert_equal true , logb.error?

      root.level = 4
      assert_equal 4, root.level
      assert_equal 4, log.level
      assert_equal 4, logb.level
      assert_equal false, root.error?
      assert_equal true,  root.fatal?
      assert_equal false, log.error?
      assert_equal true , log.fatal?
      assert_equal false, logb.error?
      assert_equal true , logb.fatal?

      log.level = nil
      assert_equal 4, root.level
      assert_equal 4, log.level
      assert_equal 4, logb.level
      assert_equal false, root.error?
      assert_equal true,  root.fatal?
      assert_equal false, log.error?
      assert_equal true , log.fatal?
      assert_equal false, logb.error?
      assert_equal true , logb.fatal?

      log.level = :DEBUG
      assert_equal 4, root.level
      assert_equal 0, log.level
      assert_equal 0, logb.level
      assert_equal false, root.error?
      assert_equal true,  root.fatal?
      assert_equal true,  log.debug?
      assert_equal true,  logb.debug?

      log.level = :off
      assert_equal 4, root.level
      assert_equal 5, log.level
      assert_equal 5, logb.level
      assert_equal false, root.error?
      assert_equal true,  root.fatal?
      assert_equal false, log.fatal?
      assert_equal false, logb.fatal?

      root.level = :all
      assert_equal 0, root.level
      assert_equal 5, log.level
      assert_equal 5, logb.level
      assert_equal true,  root.debug?
      assert_equal false, log.fatal?
      assert_equal false, logb.fatal?

      log.level = nil
      assert_equal 0, root.level
      assert_equal 0, log.level
      assert_equal 0, logb.level
      assert_equal true,  root.debug?
      assert_equal true,  log.debug?
      assert_equal true,  logb.debug?

      logb.level = :warn
      assert_equal 0, root.level
      assert_equal 0, log.level
      assert_equal 2, logb.level
      assert_equal true,  root.debug?
      assert_equal true,  log.debug?
      assert_equal false, logb.info?
      assert_equal true,  logb.warn?

      log.level  = :info
      logb.level = nil
      assert_equal 0, root.level
      assert_equal 1, log.level
      assert_equal 1, logb.level
      assert_equal true,  root.debug?
      assert_equal false, logb.debug?
      assert_equal true,  log.info?
      assert_equal false, logb.debug?
      assert_equal true,  logb.info?
    end

    def test_log
      root = ::Logging::Logger[:root]
      root.level = 'info'

      a1 = ::Logging::Appenders::StringIo.new 'a1'
      a2 = ::Logging::Appenders::StringIo.new 'a2'
      log = ::Logging::Logger.new 'A Logger'

      root.add_appenders a1
      assert_nil a1.readline
      assert_nil a2.readline

      log.debug 'this should NOT be logged'
      assert_nil a1.readline
      assert_nil a2.readline

      log.info 'this should be logged'
      assert_equal " INFO  A Logger : this should be logged\n", a1.readline
      assert_nil a1.readline
      assert_nil a2.readline

      log.warn [1,2,3,4]
      assert_equal " WARN  A Logger : <Array> #{[1,2,3,4]}\n", a1.readline
      assert_nil a1.readline
      assert_nil a2.readline

      log.add_appenders a2
      log.error 'an error has occurred'
      assert_equal "ERROR  A Logger : an error has occurred\n", a1.readline
      assert_equal "ERROR  A Logger : an error has occurred\n", a2.readline
      assert_nil a1.readline
      assert_nil a2.readline

      log.additive = false
      log.error 'another error has occurred'
      assert_equal "ERROR  A Logger : another error has occurred\n", a2.readline
      assert_nil a1.readline
      assert_nil a2.readline

      log.add_appenders a1
      log.fatal 'fatal exception'
      assert_equal "FATAL  A Logger : fatal exception\n", a1.readline
      assert_equal "FATAL  A Logger : fatal exception\n", a2.readline
      assert_nil a1.readline
      assert_nil a2.readline

      assert_equal false, log.debug
      assert_equal true, log.info
      assert_equal " INFO  A Logger : <NilClass> nil\n", a1.readline
      assert_equal " INFO  A Logger : <NilClass> nil\n", a2.readline
      assert_equal true, log.warn
      assert_equal " WARN  A Logger : <NilClass> nil\n", a1.readline
      assert_equal " WARN  A Logger : <NilClass> nil\n", a2.readline
      assert_equal true, log.error
      assert_equal "ERROR  A Logger : <NilClass> nil\n", a1.readline
      assert_equal "ERROR  A Logger : <NilClass> nil\n", a2.readline
      assert_equal true, log.fatal
      assert_equal "FATAL  A Logger : <NilClass> nil\n", a1.readline
      assert_equal "FATAL  A Logger : <NilClass> nil\n", a2.readline

      log.level = :warn
      assert_equal false, log.debug
      assert_equal false, log.info
      assert_equal true, log.warn
      assert_equal " WARN  A Logger : <NilClass> nil\n", a1.readline
      assert_equal " WARN  A Logger : <NilClass> nil\n", a2.readline
      assert_equal true, log.error
      assert_equal "ERROR  A Logger : <NilClass> nil\n", a1.readline
      assert_equal "ERROR  A Logger : <NilClass> nil\n", a2.readline
      assert_equal true, log.fatal
      assert_equal "FATAL  A Logger : <NilClass> nil\n", a1.readline
      assert_equal "FATAL  A Logger : <NilClass> nil\n", a2.readline

      assert_raise(NoMethodError) {log.critical 'this log level does not exist'}

      log.warn do
        str = 'a string of data'
        str
      end
      assert_equal " WARN  A Logger : a string of data\n", a1.readline
      assert_equal " WARN  A Logger : a string of data\n", a2.readline
      assert_nil a1.readline
      assert_nil a2.readline

      log.info do
        rb_raise(RuntimeError, "this block should not be executed")
      end
      assert_nil a1.readline
      assert_nil a2.readline
    end

    def test_log_eh
      ::Logging::Logger[:root].level = 'info'
      log = ::Logging::Logger['A Logger']

      assert_equal false, log.debug?
      assert_equal true, log.info?
      assert_equal true, log.warn?
      assert_equal true, log.error?
      assert_equal true, log.fatal?

      log.level = :warn
      assert_equal false, log.debug?
      assert_equal false, log.info?
      assert_equal true, log.warn?
      assert_equal true, log.error?
      assert_equal true, log.fatal?

      assert_raise(NoMethodError) do
        log.critical? 'this log level does not exist'
      end
    end

    def test_name
      root = ::Logging::Logger.new :root
      log  = ::Logging::Logger.new 'A'

      assert_equal 'root', root.name
      assert_equal 'A', log.name
    end

    def test_parent
      logger = ::Logging::Logger
      root = logger.new :root

      assert_raise(NoMethodError) {root.parent}

      assert_same root, logger['A'].parent
      assert_same logger['A'], logger['A::B'].parent
      assert_same logger['A::B'], logger['A::B::C::D'].parent
      assert_same logger['A::B'], logger['A::B::C::E'].parent
      assert_same logger['A::B'], logger['A::B::C::F'].parent

      assert_same logger['A::B'], logger['A::B::C'].parent
      assert_same logger['A::B::C'], logger['A::B::C::D'].parent
      assert_same logger['A::B::C'], logger['A::B::C::E'].parent
      assert_same logger['A::B::C'], logger['A::B::C::F'].parent

      assert_same logger['A::B::C::E'], logger['A::B::C::E::G'].parent
    end

    def test_remove_appenders
      log = ::Logging::Logger['X']

      appenders = lambda {log.instance_variable_get :@appenders}
      assert_equal [], appenders[]

      a = ::Logging::Appender.new 'test_appender_1'
      b = ::Logging::Appender.new 'test_appender_2'
      c = ::Logging::Appender.new 'test_appender_3'

      log.add_appenders a, b, c
      assert_equal [a,b,c], appenders[]

      assert_raise(ArgumentError) {log.remove_appenders Object.new}
      assert_raise(ArgumentError) {log.remove_appenders 10}

      log.remove_appenders b
      assert_equal [a,c], appenders[]

      log.remove_appenders 'test_appender_1'
      assert_equal [c], appenders[]

      log.remove_appenders c
      assert_equal [], appenders[]

      log.remove_appenders a, b, c
      assert_equal [], appenders[]

      log.add_appenders a, b, c
      assert_equal [a,b,c], appenders[]

      log.remove_appenders a, c
      assert_equal [b], appenders[]
    end

    def test_spaceship
      logs = %w(
        A  A::B  A::B::C  A::B::C::D  A::B::C::E  A::B::C::E::G  A::B::C::F
      ).map {|x| ::Logging::Logger[x]}
      logs.unshift ::Logging::Logger[:root]

      logs.inject do |a,b|
        assert_equal(-1, a <=> b, "'#{a.name}' <=> '#{b.name}'")
        b
      end

      assert_equal 1, logs[1] <=> ::Logging::Logger[:root]
      assert_raise(ArgumentError) {logs[1] <=> Object.new}
      assert_raise(ArgumentError) {::Logging::Logger[:root] <=> 'string'}
    end

    def test_trace
      log = ::Logging::Logger[:root]
      assert_equal false, log.trace

      log.trace = true
      assert_equal true, log.trace

      log = ::Logging::Logger['A']
      assert_equal false, log.trace

      log.trace = true
      assert_equal true, log.trace
    end

    def test_trace_eq
      log = ::Logging::Logger.new 'A'
      assert_equal false, log.trace

      log.trace = true
      assert_equal true, log.trace

      log.trace = false
      assert_equal false, log.trace

      log.trace = 'true'
      assert_equal true, log.trace

      log.trace = 'false'
      assert_equal false, log.trace

      log.trace = nil
      assert_equal false, log.trace

      assert_raise(ArgumentError) {log.trace = Object}
    end

    def test_dump_configuration
      log_a = ::Logging::Logger['A-logger']
      log_b = ::Logging::Logger['A-logger::B-logger']
      log_c = ::Logging::Logger['A-logger::B-logger::C-logger']
      log_d = ::Logging::Logger['A-logger::D-logger']

      sio = StringIO.new
      sio.extend ::Logging::Appenders::StringIo::IoToS

      log_a._dump_configuration( sio )
      assert_equal(
        "A-logger  ........................................   debug  +A  -T\n", sio.to_s)

      log_b._dump_configuration( sio )
      assert_equal(
        "A-logger::B-logger  ..............................   debug  +A  -T\n", sio.to_s)

      log_c._dump_configuration( sio )
      assert_equal(
        "A-logger::B-logger::C-logger  ....................   debug  +A  -T\n", sio.to_s)

      log_d._dump_configuration( sio )
      assert_equal(
        "A-logger::D-logger  ..............................   debug  +A  -T\n", sio.to_s)

      log_b.level = :warn
      log_b.trace = true
      log_b._dump_configuration( sio )
      assert_equal(
        "A-logger::B-logger  ..............................   *warn  +A  +T\n", sio.to_s)

      log_c.additive = false
      log_c._dump_configuration( sio )
      assert_equal(
        "A-logger::B-logger::C-logger  ....................    warn  -A  -T\n", sio.to_s)

      # with an indent specified
      log_a._dump_configuration( sio, 4 )
      assert_equal(
        "    A-logger  ....................................   debug  +A  -T\n", sio.to_s)

      log_b._dump_configuration( sio, 8 )
      assert_equal(
        "        A-logger::B-logger  ......................   *warn  +A  +T\n", sio.to_s)

      log_c._dump_configuration( sio, 10 )
      assert_equal(
        "          A-logger::B-logger::C-logger  ..........    warn  -A  -T\n", sio.to_s)

      log_d._dump_configuration( sio, 22 )
      assert_equal(
        "                      A-logger::D-logger  ........   debug  +A  -T\n", sio.to_s)

      log_c.level = 0
      log_c._dump_configuration( sio, 26 )
      assert_equal(
        "                          A-logger::B...::C-logger  *debug  -A  -T\n", sio.to_s)
    end

  end  # class TestLogger
end  # module TestLogging

