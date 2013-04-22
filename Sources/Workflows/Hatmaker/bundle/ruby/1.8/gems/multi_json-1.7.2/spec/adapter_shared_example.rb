# encoding: UTF-8

shared_examples_for 'an adapter' do |adapter|

  before do
    begin
      MultiJson.use adapter
    rescue LoadError
      pending "Adapter #{adapter} couldn't be loaded (not installed?)"
    end
  end

  it_behaves_like 'has options', lambda{ MultiJson.adapter }

  it 'does not modify argument hashes' do
    options = { :symbolize_keys => true, :pretty => false, :adapter => :json_gem }
    expect{MultiJson.load('{}', options)}.to_not change{options}
    expect{MultiJson.dump([42], options)}.to_not change{options}
  end

  describe '.dump' do
    describe '#dump_options' do
      before{ MultiJson.dump_options = MultiJson.adapter.dump_options = {} }

      after do
        MultiJson.adapter.instance.should_receive(:dump).with(1, :foo=>'bar', :fizz=>'buzz')
        MultiJson.dump(1, :fizz => 'buzz')
        MultiJson.dump_options = MultiJson.adapter.dump_options = nil
      end

      it 'respects global dump options' do
        MultiJson.dump_options = {:foo => 'bar'}
      end

      it 'respects per-adapter dump options' do
        MultiJson.adapter.dump_options = {:foo => 'bar'}
      end

      it 'adapter-specific are overridden by global options' do
        MultiJson.adapter.dump_options = {:foo => 'foo'}
        MultiJson.dump_options = {:foo => 'bar'}
      end
    end

    it 'writes decodable JSON' do
      [
        {'abc' => 'def'},
        [1, 2, 3, '4', true, false, nil]
      ].each do |example|
        expect(MultiJson.load(MultiJson.dump(example))).to eq example
      end
    end

    unless 'json_pure' == adapter || 'json_gem' == adapter
      it 'dumps time in correct format' do
        time = Time.at(1355218745).utc

        # time does not respond to to_json method
        class << time
          undef_method :to_json
        end

        dumped_json = MultiJson.dump(time)
        expected = if RUBY_VERSION > '1.9'
          '2012-12-11 09:39:05 UTC'
        else
          'Tue Dec 11 09:39:05 UTC 2012'
        end
        expect(MultiJson.load(dumped_json)).to eq expected
      end
    end

    it 'dumps symbol and fixnum keys as strings' do
      [
        [
          {:foo => {:bar => 'baz'}},
          {'foo' => {'bar' => 'baz'}},
        ],
        [
          [{:foo => {:bar => 'baz'}}],
          [{'foo' => {'bar' => 'baz'}}],
        ],
        [
          {:foo => [{:bar => 'baz'}]},
          {'foo' => [{'bar' => 'baz'}]},
        ],
        [
          {1 => {2 => {3 => 'bar'}}},
          {'1' => {'2' => {'3' => 'bar'}}}
        ]
      ].each do |example, expected|
        dumped_json = MultiJson.dump(example)
        expect(MultiJson.load(dumped_json)).to eq expected
      end
    end

    it 'dumps rootless JSON' do
      expect(MultiJson.dump('random rootless string')).to eq '"random rootless string"'
      expect(MultiJson.dump(123)).to eq '123'
    end

    it 'passes options to the adapter' do
      MultiJson.adapter.should_receive(:dump).with('foo', {:bar => :baz})
      MultiJson.dump('foo', :bar => :baz)
    end

    # This behavior is currently not supported by gson.rb
    # See discussion at https://github.com/intridea/multi_json/pull/71
    unless %w(gson jr_jackson).include?(adapter)
      it 'dumps custom objects that implement to_json' do
        klass = Class.new do
          def to_json(*)
            '"foobar"'
          end
        end
        expect(MultiJson.dump(klass.new)).to eq '"foobar"'
      end
    end

    it 'allows to dump JSON values' do
      expect(MultiJson.dump(42)).to eq '42'
    end

    it 'allows to dump JSON with UTF-8 characters' do
      expect(MultiJson.dump({'color' => 'żółć'})).to eq('{"color":"żółć"}')
    end
  end

  describe '.load' do
    describe '#load_options' do
      before{ MultiJson.load_options = MultiJson.adapter.load_options = {} }

      after do
        MultiJson.adapter.instance.should_receive(:load).with('1', :foo => 'bar', :fizz => 'buzz')
        MultiJson.load('1', :fizz => 'buzz')
        MultiJson.load_options = MultiJson.adapter.load_options = nil
      end

      it 'respects global load options' do
        MultiJson.load_options = {:foo => 'bar'}
      end

      it 'respects per-adapter load options' do
        MultiJson.adapter.load_options = {:foo => 'bar'}
      end

      it 'adapter-specific are overridden by global options' do
        MultiJson.adapter.load_options = {:foo => 'foo'}
        MultiJson.load_options = {:foo => 'bar'}
      end
    end

    it 'does not modify input' do
      input = %Q{\n\n  {"foo":"bar"} \n\n\t}
      expect{
        MultiJson.load(input)
      }.to_not change{ input }
    end

    it 'does not modify input encoding' do
      pending 'only in 1.9' unless RUBY_VERSION > '1.9'

      input = '[123]'
      input.force_encoding('iso-8859-1')

      expect{
        MultiJson.load(input)
      }.to_not change{ input.encoding }
    end

    it 'properly loads valid JSON' do
      expect(MultiJson.load('{"abc":"def"}')).to eq({'abc' => 'def'})
    end

    it 'raises MultiJson::LoadError on invalid JSON' do
      expect{MultiJson.load('{"abc"}')}.to raise_error(MultiJson::LoadError)
    end

    it 'raises MultiJson::LoadError with data on invalid JSON' do
      data = '{invalid}'
      begin
        MultiJson.load(data)
      rescue MultiJson::LoadError => le
        expect(le.data).to eq data
      end
    end

    it 'catches MultiJson::DecodeError for legacy support' do
      data = '{invalid}'
      begin
        MultiJson.load(data)
      rescue MultiJson::DecodeError => de
        expect(de.data).to eq data
      end
    end

    it 'stringifys symbol keys when encoding' do
      dumped_json = MultiJson.dump(:a => 1, :b => {:c => 2})
      expect(MultiJson.load(dumped_json)).to eq({'a' => 1, 'b' => {'c' => 2}})
    end

    it 'properly loads valid JSON in StringIOs' do
      json = StringIO.new('{"abc":"def"}')
      expect(MultiJson.load(json)).to eq({'abc' => 'def'})
    end

    it 'allows for symbolization of keys' do
      [
        [
          '{"abc":{"def":"hgi"}}',
          {:abc => {:def => 'hgi'}},
        ],
        [
          '[{"abc":{"def":"hgi"}}]',
          [{:abc => {:def => 'hgi'}}],
        ],
        [
          '{"abc":[{"def":"hgi"}]}',
          {:abc => [{:def => 'hgi'}]},
        ],
      ].each do |example, expected|
        expect(MultiJson.load(example, :symbolize_keys => true)).to eq expected
      end
    end

    it 'allows to load JSON values' do
      expect(MultiJson.load('42')).to eq 42
    end

    it 'allows to load JSON with UTF-8 characters' do
      expect(MultiJson.load('{"color":"żółć"}')).to eq({'color' => 'żółć'})
    end
  end
end
