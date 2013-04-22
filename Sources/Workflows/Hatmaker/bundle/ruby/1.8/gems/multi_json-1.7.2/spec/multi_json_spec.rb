require 'helper'
require 'adapter_shared_example'
require 'json_common_shared_example'
require 'has_options'
require 'stringio'

describe 'MultiJson' do
  context 'adapters' do
    before{ MultiJson.use nil }

    context 'when no other json implementations are available' do
      before do
        @old_map = MultiJson::REQUIREMENT_MAP
        @old_json = Object.const_get :JSON if Object.const_defined?(:JSON)
        @old_oj = Object.const_get :Oj if Object.const_defined?(:Oj)
        @old_yajl = Object.const_get :Yajl if Object.const_defined?(:Yajl)
        @old_gson = Object.const_get :Gson if Object.const_defined?(:Gson)
        MultiJson::REQUIREMENT_MAP.each_with_index do |(library, adapter), index|
          MultiJson::REQUIREMENT_MAP[index] = ["foo/#{library}", adapter]
        end
        Object.send :remove_const, :JSON if @old_json
        Object.send :remove_const, :Oj if @old_oj
        Object.send :remove_const, :Yajl if @old_yajl
        Object.send :remove_const, :Gson if @old_gson
      end

      after do
        @old_map.each_with_index do |(library, adapter), index|
          MultiJson::REQUIREMENT_MAP[index] = [library, adapter]
        end
        Object.const_set :JSON, @old_json if @old_json
        Object.const_set :Oj, @old_oj if @old_oj
        Object.const_set :Yajl, @old_yajl if @old_yajl
        Object.const_set :Gson, @old_gson if @old_gson
      end

      it 'defaults to ok_json if no other json implementions are available' do
        silence_warnings do
          expect(MultiJson.default_adapter).to eq :ok_json
        end
      end

      it 'prints a warning' do
        Kernel.should_receive(:warn).with(/warning/i)
        MultiJson.default_adapter
      end
    end

    it 'defaults to the best available gem' do
      # Clear cache variable already set by previous tests
      MultiJson.send(:remove_instance_variable, :@adapter)
      unless jruby?
        expect(MultiJson.adapter).to eq MultiJson::Adapters::Oj
      else
        expect(MultiJson.adapter).to eq MultiJson::Adapters::JsonGem
      end
    end

    it 'looks for adapter even if @adapter variable is nil' do
      MultiJson.send(:instance_variable_set, :@adapter, nil)
      MultiJson.should_receive(:default_adapter).and_return(:ok_json)
      expect(MultiJson.adapter).to eq MultiJson::Adapters::OkJson
    end

    it 'is settable via a symbol' do
      MultiJson.use :json_gem
      expect(MultiJson.adapter).to eq MultiJson::Adapters::JsonGem
    end

    it 'is settable via a class' do
      adapter = Class.new
      MultiJson.use adapter
      expect(MultiJson.adapter).to eq adapter
    end

    it 'is settable via a module' do
      adapter = Module.new
      MultiJson.use adapter
      expect(MultiJson.adapter).to eq adapter
    end

    it 'throws ArgumentError on bad input' do
      expect{ MultiJson.use 'bad adapter' }.to raise_error(ArgumentError)
    end

    context 'using one-shot parser' do
      before do
        MultiJson::Adapters::JsonPure.should_receive(:dump).once.and_return('dump_something')
        MultiJson::Adapters::JsonPure.should_receive(:load).once.and_return('load_something')
      end

      it 'should use the defined parser just for the call' do
        MultiJson.use :json_gem
        expect(MultiJson.dump('', :adapter => :json_pure)).to eq 'dump_something'
        expect(MultiJson.load('', :adapter => :json_pure)).to eq 'load_something'
        expect(MultiJson.adapter).to eq MultiJson::Adapters::JsonGem
      end
    end
  end

  it 'can set adapter for a block' do
    MultiJson.use :ok_json
    MultiJson.with_adapter(:json_pure) do
      MultiJson.with_engine(:json_gem) do
        expect(MultiJson.adapter).to eq MultiJson::Adapters::JsonGem
      end
      expect(MultiJson.adapter).to eq MultiJson::Adapters::JsonPure
    end
    expect(MultiJson.adapter).to eq MultiJson::Adapters::OkJson
  end

  it 'JSON gem does not create symbols on parse' do
    MultiJson.with_engine(:json_gem) do
      MultiJson.load('{"json_class":"ZOMG"}') rescue nil

      expect{
        MultiJson.load('{"json_class":"OMG"}') rescue nil
      }.to_not change{Symbol.all_symbols.count}
    end
  end

  unless jruby?
    it 'Oj does not create symbols on parse' do
      MultiJson.with_engine(:oj) do
        MultiJson.load('{"json_class":"ZOMG"}') rescue nil

        expect{
          MultiJson.load('{"json_class":"OMG"}') rescue nil
        }.to_not change{Symbol.all_symbols.count}
      end
    end

    context 'with Oj.default_settings' do

      around do |example|
        options = Oj.default_options
        Oj.default_options = { :symbol_keys => true }
        MultiJson.with_engine(:oj){ example.call }
        Oj.default_options = options
      end

      it 'ignores global settings' do
        MultiJson.with_engine(:oj) do
          example = '{"a": 1, "b": 2}'
          expected = { 'a' => 1, 'b' => 2 }
          expect(MultiJson.load(example)).to eq expected
        end
      end
    end
  end

  describe 'default options' do
    after(:all){ MultiJson.load_options = MultiJson.dump_options = nil }

    it 'is deprecated' do
      Kernel.should_receive(:warn).with(/deprecated/i)
      silence_warnings{ MultiJson.default_options = {:foo => 'bar'} }
    end

    it 'sets both load and dump options' do
      MultiJson.should_receive(:dump_options=).with(:foo => 'bar')
      MultiJson.should_receive(:load_options=).with(:foo => 'bar')
      silence_warnings{ MultiJson.default_options = {:foo => 'bar'} }
    end
  end

  it_behaves_like 'has options', MultiJson

  %w(gson jr_jackson json_gem json_pure nsjsonserialization oj ok_json yajl).each do |adapter|
    next if !jruby? && %w(gson jr_jackson).include?(adapter)
    next if !macruby? && adapter == 'nsjsonserialization'
    next if jruby? && %w(oj yajl).include?(adapter)

    context adapter do
      it_behaves_like 'an adapter', adapter
    end
  end

  %w(json_gem json_pure).each do |adapter|
    context adapter do
      it_behaves_like 'JSON-like adapter', adapter
    end
  end

  describe 'aliases' do
    if jruby?
      describe 'jrjackson' do
        after{ expect(MultiJson.adapter).to eq(MultiJson::Adapters::JrJackson) }

        it 'allows jrjackson alias as symbol' do
          expect{ MultiJson.use :jrjackson }.not_to raise_error
        end

        it 'allows jrjackson alias as string' do
          expect{ MultiJson.use 'jrjackson' }.not_to raise_error
        end

      end
    end
  end
end
