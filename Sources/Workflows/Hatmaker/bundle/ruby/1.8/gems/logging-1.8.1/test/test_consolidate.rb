
require File.expand_path('setup', File.dirname(__FILE__))

module TestLogging

  class TestConsolidate < Test::Unit::TestCase
    include LoggingTestCase

    def test_root
      Logging.consolidate :root
      root = Logging.logger.root

      assert_same root, Logging.logger['Foo']
      assert_same root, Logging.logger['Foo::Bar']
      assert_same root, Logging.logger[Array]
    end

    def test_foo
      Logging.consolidate 'Foo'
      logger = Logging.logger['Foo::Bar::Baz']

      assert_same Logging.logger['Foo'], logger
      assert_not_same Logging.logger.root, logger
    end

    def test_many
      Logging.consolidate 'Foo', 'root', 'Foo::Bar::Baz'

      root = Logging.logger.root
      foo = Logging.logger['Foo']
      fbb = Logging.logger['Foo::Bar::Baz']

      assert_not_same root, foo
      assert_not_same root, fbb
      assert_not_same foo, fbb

      assert_same root, Logging.logger[Hash]
      assert_same root, Logging.logger['ActiveRecord::Base']
      assert_same foo, Logging.logger['Foo::Bar']
      assert_same fbb, Logging.logger['Foo::Bar::Baz::Buz']
    end

  end  # class TestConsolidate
end  # module TestLogging

