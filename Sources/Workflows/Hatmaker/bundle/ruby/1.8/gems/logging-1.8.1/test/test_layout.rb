
require File.expand_path('setup', File.dirname(__FILE__))

module TestLogging

  class TestLayout < Test::Unit::TestCase
    include LoggingTestCase

    def setup
      super
      @layout = ::Logging::Layout.new
    end

    def test_header
      assert_equal '', @layout.header
    end

    def test_initialize
      obj_format = lambda {|l| l.instance_variable_get :@obj_format}

      assert_equal :string, obj_format[@layout]

      @layout = ::Logging::Layout.new 'format_as' => 'blah'
      assert_equal :string, obj_format[@layout]

      @layout = ::Logging::Layout.new :format_as => :inspect
      assert_equal :inspect, obj_format[@layout]

      @layout = ::Logging::Layout.new 'format_as' => :json
      assert_equal :json, obj_format[@layout]

      @layout = ::Logging::Layout.new 'format_as' => :yaml
      assert_equal :yaml, obj_format[@layout]

      @layout = ::Logging::Layout.new
      assert_equal :string, obj_format[@layout]

      ::Logging.format_as :yaml
      @layout = ::Logging::Layout.new
      assert_equal :yaml, obj_format[@layout]
    end

    def test_footer
      assert_equal '', @layout.footer
    end

    def test_format
      assert_nil @layout.format(::Logging::LogEvent.new('a','b','c',false))
    end

    def test_format_obj
      obj = 'test string'
      r = @layout.format_obj obj
      assert_same obj, r

      obj = RuntimeError.new
      r = @layout.format_obj obj
      assert_equal '<RuntimeError> RuntimeError', r

      obj = TypeError.new 'only works with Integers'
      r = @layout.format_obj obj
      assert_equal '<TypeError> only works with Integers', r

      obj = Exception.new 'some exception'
      obj.set_backtrace %w( this is the backtrace )
      r = @layout.format_obj obj
      obj = "<Exception> some exception\n\tthis\n\tis\n\tthe\n\tbacktrace"
      assert_equal obj, r

      obj = [1, 2, 3, 4]
      r = @layout.format_obj obj
      assert_equal "<Array> #{[1,2,3,4]}", r

      obj = %w( one two three four )
      @layout = ::Logging::Layout.new :format_as => :inspect
      r = @layout.format_obj obj
      assert_equal '<Array> ["one", "two", "three", "four"]', r

      @layout = ::Logging::Layout.new :format_as => :json
      r = @layout.format_obj obj
      assert_equal '<Array> ["one","two","three","four"]', r

      @layout = ::Logging::Layout.new :format_as => :yaml
      r = @layout.format_obj obj
      assert_match %r/\A<Array> \n--- ?\n- one\n- two\n- three\n- four\n/, r

      r = @layout.format_obj Class
      if defined? YAML::ENGINE and YAML::ENGINE.yamler == 'psych'
        assert_equal "<Class> \n--- !ruby/class 'Class'\n", r
      else
        assert_equal "<Class> Class", r
      end
    end

    def test_format_obj_without_backtrace
      @layout = ::Logging::Layout.new :backtrace => 'off'

      obj = Exception.new 'some exception'
      obj.set_backtrace %w( this is the backtrace )
      r = @layout.format_obj obj
      obj = "<Exception> some exception"
      assert_equal obj, r

      ::Logging.backtrace :off
      @layout = ::Logging::Layout.new

      obj = ArgumentError.new 'wrong type of argument'
      obj.set_backtrace %w( this is the backtrace )
      r = @layout.format_obj obj
      obj = "<ArgumentError> wrong type of argument"
      assert_equal obj, r
    end

    def test_initializer
      assert_raise(ArgumentError) {::Logging::Layout.new :backtrace => 'foo'}
    end

  end  # class TestLayout
end  # module TestLogging

