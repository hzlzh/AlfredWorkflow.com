shared_examples_for "an adapter" do |adapter|

  before do
    begin
      MultiJson.use adapter
    rescue LoadError
      pending "Adapter #{adapter} couldn't be loaded (not installed?)"
    end
  end

  describe '.dump' do
    it 'writes decodable JSON' do
      [
        {'abc' => 'def'},
        [1, 2, 3, "4"],
      ].each do |example|
        expect(MultiJson.load(MultiJson.dump(example))).to eq example
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
      expect(MultiJson.dump("random rootless string")).to eq "\"random rootless string\""
      expect(MultiJson.dump(123)).to eq "123"
    end

    it 'passes options to the adapter' do
      MultiJson.adapter.should_receive(:dump).with('foo', {:bar => :baz})
      MultiJson.dump('foo', :bar => :baz)
    end

    if adapter == 'json_gem' || adapter == 'json_pure'
      describe 'with :pretty option set to true' do
        it 'passes default pretty options' do
          object = 'foo'
          object.should_receive(:to_json).with(JSON::PRETTY_STATE_PROTOTYPE.to_h)
          MultiJson.dump(object,:pretty => true)
        end
      end
    end

    it 'dumps custom objects which implement as_json' do
      expect(MultiJson.dump(TimeWithZone.new)).to eq "\"2005-02-01T15:15:10Z\""
    end

    it 'allow to dump JSON values' do
      expect(MultiJson.dump(42)).to eq '42'
    end

  end

  describe '.load' do
    it 'properly loads valid JSON' do
      expect(MultiJson.load('{"abc":"def"}')).to eq({'abc' => 'def'})
    end

    it 'raises MultiJson::DecodeError on invalid JSON' do
      expect{MultiJson.load('{"abc"}')}.to raise_error(MultiJson::DecodeError)
    end

    it 'raises MultiJson::DecodeError with data on invalid JSON' do
      data = '{invalid}'
      begin
        MultiJson.load(data)
      rescue MultiJson::DecodeError => de
        expect(de.data).to eq data
      end
    end

    it 'stringifys symbol keys when encoding' do
      dumped_json = MultiJson.dump(:a => 1, :b => {:c => 2})
      expect(MultiJson.load(dumped_json)).to eq({"a" => 1, "b" => {"c" => 2}})
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

    it 'allow to load JSON values' do
      expect(MultiJson.load('42')).to eq 42
    end

  end
end
