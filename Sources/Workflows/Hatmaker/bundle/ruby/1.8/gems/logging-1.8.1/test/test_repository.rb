
require File.expand_path('setup', File.dirname(__FILE__))

module TestLogging

  class TestRepository < Test::Unit::TestCase
    include LoggingTestCase

    def setup
      super
      @repo = ::Logging::Repository.instance
    end

    def test_instance
      assert_same @repo, ::Logging::Repository.instance
    end

    def test_aref
      root = @repo[:root]
      assert_same root, @repo[:root]

      a = []
      ::Logging::Logger.new a
      assert_same @repo['Array'], @repo[Array]
      assert_same @repo['Array'], @repo[a]

      assert_not_same @repo['Array'], @repo[:root]

      ::Logging::Logger.new 'A'
      ::Logging::Logger.new 'A::B'
      assert_not_same @repo['A'], @repo['A::B']
    end

    def test_aset
      root = @repo[:root]
      @repo[:root] = 'root'
      assert_not_same root, @repo[:root]

      assert_nil @repo['blah']
      @repo['blah'] = 'root'
      assert_equal 'root', @repo['blah']
    end

    def test_fetch
      assert @repo.has_logger?(:root)
      assert_same @repo[:root], @repo.fetch(:root)

      assert !@repo.has_logger?('A')
      assert_raise(KeyError) {@repo.fetch 'A'}

      %w(A A::B A::B::C::D A::B::C::E A::B::C::F).each do |name|
        ::Logging::Logger.new(name)
      end

      assert @repo.has_logger?('A')
      assert @repo.has_logger?('A::B')
    end

    def test_parent
      %w(A A::B A::B::C::D A::B::C::E A::B::C::F).each do |name|
        ::Logging::Logger.new(name)
      end

      assert_same @repo[:root], @repo.parent('A')
      assert_same @repo['A'], @repo.parent('A::B')
      assert_same @repo['A::B'], @repo.parent('A::B::C')
      assert_same @repo['A::B'], @repo.parent('A::B::C::D')
      assert_same @repo['A::B'], @repo.parent('A::B::C::E')
      assert_same @repo['A::B'], @repo.parent('A::B::C::F')

      ::Logging::Logger.new('A::B::C')

      assert_same @repo['A::B'], @repo.parent('A::B::C')
      assert_same @repo['A::B::C'], @repo.parent('A::B::C::D')
      assert_same @repo['A::B::C'], @repo.parent('A::B::C::E')
      assert_same @repo['A::B::C'], @repo.parent('A::B::C::F')

      ::Logging::Logger.new('A::B::C::E::G')

      assert_same @repo['A::B::C::E'], @repo.parent('A::B::C::E::G')

      assert_nil @repo.parent('root')
    end

    def test_children
      ::Logging::Logger.new('A')

      assert_equal [], @repo.children('A')

      ::Logging::Logger.new('A::B')
      a = %w(D E F).map {|name| ::Logging::Logger.new('A::B::C::'+name)}.sort

      assert_equal [@repo['A::B']], @repo.children('A')
      assert_equal a, @repo.children('A::B')
      assert_equal [], @repo.children('A::B::C')

      ::Logging::Logger.new('A::B::C')

      assert_equal [@repo['A::B::C']], @repo.children('A::B')
      assert_equal a, @repo.children('A::B::C')

      ::Logging::Logger.new('A::B::C::E::G')

      assert_equal a, @repo.children('A::B::C')
      assert_equal [@repo['A::B::C::E::G']], @repo.children('A::B::C::E')

      assert_equal [@repo['A'], @repo['Logging']], @repo.children('root')
    end

    def test_to_key
      assert_equal :root, @repo.to_key(:root)
      assert_equal 'Object', @repo.to_key('Object')
      assert_equal 'Object', @repo.to_key(Object)
      assert_equal 'Object', @repo.to_key(Object.new)

      assert_equal 'String', @repo.to_key(String)
      assert_equal 'Array', @repo.to_key([])

      assert_equal 'blah', @repo.to_key('blah')
      assert_equal 'blah', @repo.to_key(:blah)
    end

    def test_add_master
      ary = @repo.instance_variable_get(:@masters)
      assert ary.empty?

      @repo.add_master 'root'
      assert_equal [:root], ary

      @repo.add_master Object, 'Foo'
      assert_equal [:root, 'Object', 'Foo'], ary
    end

    def test_master_for
      assert_nil @repo.master_for('root')
      assert_nil @repo.master_for('Foo::Bar::Baz')

      @repo.add_master('Foo')
      assert_equal 'Foo', @repo.master_for('Foo')
      assert_equal 'Foo', @repo.master_for('Foo::Bar::Baz')

      @repo.add_master('Foo::Bar::Baz')
      assert_equal 'Foo', @repo.master_for('Foo')
      assert_equal 'Foo', @repo.master_for('Foo::Bar')
      assert_equal 'Foo::Bar::Baz', @repo.master_for('Foo::Bar::Baz')
      assert_equal 'Foo::Bar::Baz', @repo.master_for('Foo::Bar::Baz::Buz')

      assert_nil @repo.master_for('Bar::Baz::Buz')
      @repo.add_master 'root'
      assert_equal :root, @repo.master_for('Bar::Baz::Buz')
      assert_equal 'Foo', @repo.master_for('Foo::Bar')
      assert_equal 'Foo::Bar::Baz', @repo.master_for('Foo::Bar::Baz::Buz')
    end

  end  # class TestRepository
end  # module TestLogging

