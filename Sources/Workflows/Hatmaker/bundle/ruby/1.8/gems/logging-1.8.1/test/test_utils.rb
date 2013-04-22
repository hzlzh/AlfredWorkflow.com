
require File.expand_path('setup', File.dirname(__FILE__))

module TestLogging

  class TestUtils < Test::Unit::TestCase

    def test_hash_getopt
      opts = {
        :foo => 'foo_value',
        'bar' => 'bar_value',
        'one' => '1',
        :two => '2',
        :three => 3.0
      }

      assert_equal('foo_value', opts.getopt(:foo))
      assert_equal('foo_value', opts.getopt('foo'))
      assert_equal(:foo_value, opts.getopt(:foo, :as => Symbol))

      assert_equal('bar_value', opts.getopt(:bar))
      assert_equal('bar_value', opts.getopt('bar'))

      assert_equal('1', opts.getopt(:one))
      assert_equal(1, opts.getopt('one', :as => Integer))
      assert_instance_of(Float, opts.getopt('one', :as => Float))

      assert_equal('2', opts.getopt(:two))
      assert_equal(['2'], opts.getopt(:two, :as => Array))

      assert_equal(3.0, opts.getopt(:three))
      assert_equal('3.0', opts.getopt('three', :as => String))

      assert_equal(nil, opts.getopt(:baz))
      assert_equal('default', opts.getopt('baz', 'default'))
      assert_equal(:default, opts.getopt(:key, 'default', :as => Symbol))
      assert_equal(['default'], opts.getopt('key', 'default', :as => Array))

      assert_equal(3.0, opts.getopt(:three, :as => Object))

      assert_nil opts.getopt(:key, :as => Symbol)
    end

    def test_string_reduce
      str = 'this is the foobar string'
      len = str.length

      r = str.reduce(len + 1)
      assert_same str, r

      r = str.reduce(len)
      assert_same str, r

      r = str.reduce(len - 1)
      assert_equal 'this is the...bar string', r

      r = str.reduce(len - 10)
      assert_equal 'this i...string', r

      r = str.reduce(4)
      assert_equal 't...', r

      r = str.reduce(3)
      assert_equal '...', r

      r = str.reduce(0)
      assert_equal '...', r

      assert_raises(ArgumentError) { str.reduce(-1) }

      r = str.reduce(len - 1, '##')
      assert_equal 'this is the##obar string', r

      r = str.reduce(len - 10, '##')
      assert_equal 'this is##string', r

      r = str.reduce(4, '##')
      assert_equal 't##g', r

      r = str.reduce(3, '##')
      assert_equal 't##', r

      r = str.reduce(0, '##')
      assert_equal '##', r
    end

    def test_logger_name
      assert_equal 'Array', Array.logger_name

      # some lines are commented out for compatibility with ruby 1.9

      c = Class.new(Array)
#     assert_equal '', c.name
      assert_equal 'Array', c.logger_name

      meta = class << Array; self; end
#     assert_equal '', meta.name
      assert_equal 'Array', meta.logger_name

      m = Module.new
#     assert_equal '', m.name
      assert_equal 'anonymous', m.logger_name

      c = Class.new(::Logging::Logger)
#     assert_equal '', c.name
      assert_equal 'Logging::Logger', c.logger_name

      meta = class << ::Logging::Logger; self; end
#     assert_equal '', meta.name
      assert_equal 'Logging::Logger', meta.logger_name
    end

  end  # class TestUtils
end  # module TestLogging

