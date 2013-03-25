require 'helper'
require 'adapter_shared_example'
require 'stringio'

describe 'MultiJson' do
  context 'adapters' do
    before do
      MultiJson.use nil
    end
    context 'when no other json implementations are available' do
      before do
        @old_map = MultiJson::REQUIREMENT_MAP
        @old_json = Object.const_get :JSON if Object.const_defined?(:JSON)
        @old_oj = Object.const_get :Oj if Object.const_defined?(:Oj)
        @old_yajl = Object.const_get :Yajl if Object.const_defined?(:Yajl)
        MultiJson::REQUIREMENT_MAP.each_with_index do |(library, adapter), index|
          MultiJson::REQUIREMENT_MAP[index] = ["foo/#{library}", adapter]
        end
        Object.send :remove_const, :JSON if @old_json
        Object.send :remove_const, :Oj if @old_oj
        Object.send :remove_const, :Yajl if @old_yajl
      end

      after do
        @old_map.each_with_index do |(library, adapter), index|
          MultiJson::REQUIREMENT_MAP[index] = [library, adapter]
        end
        Object.const_set :JSON, @old_json if @old_json
        Object.const_set :Oj, @old_oj if @old_oj
        Object.const_set :Yajl, @old_yajl if @old_yajl
      end

      it 'defaults to ok_json if no other json implementions are available' do
        expect(MultiJson.default_adapter).to eq :ok_json
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
        require 'oj'
        expect(MultiJson.adapter.name).to eq 'MultiJson::Adapters::Oj'
      else
        require 'json'
        expect(MultiJson.adapter.name).to eq 'MultiJson::Adapters::JsonGem'
      end
    end

    it 'is settable via a symbol' do
      MultiJson.use :json_gem
      expect(MultiJson.adapter.name).to eq 'MultiJson::Adapters::JsonGem'
    end

    it 'is settable via a class' do
      MultiJson.use MockDecoder
      expect(MultiJson.adapter.name).to eq 'MockDecoder'
    end

    context "using one-shot parser" do
      before(:each) do
        require 'multi_json/adapters/json_pure'
        MultiJson::Adapters::JsonPure.should_receive(:dump).exactly(1).times.and_return('dump_something')
        MultiJson::Adapters::JsonPure.should_receive(:load).exactly(1).times.and_return('load_something')
      end

      it "should use the defined parser just for the call" do
        MultiJson.use :json_gem
        expect(MultiJson.dump('', :adapter => :json_pure)).to eq 'dump_something'
        expect(MultiJson.load('', :adapter => :json_pure)).to eq 'load_something'
        expect(MultiJson.adapter.name).to eq "MultiJson::Adapters::JsonGem"
      end
    end
  end

  it 'can set adapter for a block' do
    MultiJson.use :ok_json
    MultiJson.with_adapter(:json_pure) do
      expect(MultiJson.adapter.name).to eq 'MultiJson::Adapters::JsonPure'
    end
    MultiJson.with_engine(:yajl) do
      expect(MultiJson.adapter.name).to eq 'MultiJson::Adapters::Yajl'
    end
    expect(MultiJson.adapter.name).to eq 'MultiJson::Adapters::OkJson'
  end

  %w(json_gem json_pure nsjsonserialization oj ok_json yajl).each do |adapter|
    next if !macruby? && adapter == 'nsjsonserialization'
    next if jruby? && (adapter == 'oj' || adapter == 'yajl')

    context adapter do
      it_behaves_like "an adapter", adapter
    end
  end
end
