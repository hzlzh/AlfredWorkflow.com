require 'multi_json/options'
require 'multi_json/version'

module MultiJson
  include Options
  extend self

  class LoadError < StandardError
    attr_reader :data
    def initialize(message='', backtrace=[], data='')
      super(message)
      self.set_backtrace(backtrace)
      @data = data
    end
  end
  DecodeError = LoadError # Legacy support

  # Since `default_options` is deprecated, the
  # reader is aliased to `dump_options` and the
  # writer sets both `dump_options` and `load_options`
  alias default_options dump_options

  def default_options=(value)
    Kernel.warn "MultiJson.default_options setter is deprecated\n" +
      "Use MultiJson.load_options and MultiJson.dump_options instead"

    self.load_options = self.dump_options = value
  end

  ALIASES = {
    'jrjackson' => :jr_jackson
  }

  REQUIREMENT_MAP = [
    ['oj',           :oj],
    ['yajl',         :yajl],
    ['json',         :json_gem],
    ['gson',         :gson],
    ['jrjackson_r',  :jr_jackson],
    ['json/pure',    :json_pure]
  ]

  # The default adapter based on what you currently
  # have loaded and installed. First checks to see
  # if any adapters are already loaded, then checks
  # to see which are installed if none are loaded.
  def default_adapter
    return :oj if defined?(::Oj)
    return :yajl if defined?(::Yajl)
    return :json_gem if defined?(::JSON)
    return :gson if defined?(::Gson)

    REQUIREMENT_MAP.each do |(library, adapter)|
      begin
        require library
        return adapter
      rescue ::LoadError
        next
      end
    end

    Kernel.warn '[WARNING] MultiJson is using the default adapter (ok_json). We recommend loading a different JSON library to improve performance.'
    :ok_json
  end
  alias default_engine default_adapter

  # Get the current adapter class.
  def adapter
    return @adapter if defined?(@adapter) && @adapter

    self.use nil # load default adapter

    @adapter
  end
  alias engine adapter

  # Set the JSON parser utilizing a symbol, string, or class.
  # Supported by default are:
  #
  # * <tt>:oj</tt>
  # * <tt>:json_gem</tt>
  # * <tt>:json_pure</tt>
  # * <tt>:ok_json</tt>
  # * <tt>:yajl</tt>
  # * <tt>:nsjsonserialization</tt> (MacRuby only)
  # * <tt>:gson</tt> (JRuby only)
  def use(new_adapter)
    @adapter = load_adapter(new_adapter)
  end
  alias adapter= use
  alias engine= use

  def load_adapter(new_adapter)
    case new_adapter
    when String, Symbol
      new_adapter = ALIASES.fetch(new_adapter.to_s, new_adapter)
      require "multi_json/adapters/#{new_adapter}"
      klass_name = new_adapter.to_s.split('_').map(&:capitalize) * ''
      MultiJson::Adapters.const_get(klass_name)
    when NilClass, FalseClass
      load_adapter default_adapter
    when Class, Module
      new_adapter
    else
      raise NameError
    end
  rescue NameError, ::LoadError
    raise ArgumentError, 'Did not recognize your adapter specification.'
  end

  # Decode a JSON string into Ruby.
  #
  # <b>Options</b>
  #
  # <tt>:symbolize_keys</tt> :: If true, will use symbols instead of strings for the keys.
  # <tt>:adapter</tt> :: If set, the selected adapter will be used for this call.
  def load(string, options={})
    adapter = current_adapter(options)
    begin
      adapter.load(string, options)
    rescue adapter::ParseError => exception
      raise LoadError.new(exception.message, exception.backtrace, string)
    end
  end
  alias decode load

  def current_adapter(options={})
    if new_adapter = options[:adapter]
      load_adapter(new_adapter)
    else
      adapter
    end
  end

  # Encodes a Ruby object as JSON.
  def dump(object, options={})
    current_adapter(options).dump(object, options)
  end
  alias encode dump

  #  Executes passed block using specified adapter.
  def with_adapter(new_adapter)
    old_adapter, self.adapter = adapter, new_adapter
    yield
  ensure
    self.adapter = old_adapter
  end
  alias with_engine with_adapter

end
