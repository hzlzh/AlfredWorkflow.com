
module Logging::Config

  # The YamlConfigurator class is used to configure the Logging framework
  # using information found in a YAML file.
  #
  class YamlConfigurator

    class Error < StandardError; end  # :nodoc:

    class << self

      # call-seq:
      #    YamlConfigurator.load( file, key = 'logging_config' )
      #
      # Load the given YAML _file_ and use it to configure the Logging
      # framework. The file can be either a filename, and open File, or an
      # IO object. If it is the latter two, the File / IO object will not be
      # closed by this method.
      #
      # The configuration will be loaded from the given _key_ in the YAML
      # stream.
      #
      def load( file, key = 'logging_config' )
        io, close = nil, false
        case file
        when String
          io = File.open(file, 'r')
          close = true
        when IO
          io = file
        else
          raise Error, 'expecting a filename or a File'
        end

        begin
          new(io, key).load
        ensure
          io.close if close
        end
        nil
      end
    end  # class << self

    # call-seq:
    #    YamlConfigurator.new( io, key )
    #
    # Creates a new YAML configurator that will load the Logging
    # configuration from the given _io_ stream. The configuration will be
    # loaded from the given _key_ in the YAML stream.
    #
    def initialize( io, key  )
      YAML.load_documents(io) do |doc|
        @config = doc[key]
        break if @config.instance_of?(Hash)
      end

      unless @config.instance_of?(Hash)
        raise Error, "Key '#{key}' not defined in YAML configuration"
      end
    end

    # call-seq:
    #    load
    #
    # Loads the Logging configuration from the data loaded from the YAML
    # file.
    #
    def load
      pre_config @config['pre_config']
      ::Logging::Logger[:root]  # ensures the log levels are defined
      appenders @config['appenders']
      loggers @config['loggers']
    end

    # call-seq:
    #    pre_config( config )
    #
    # Configures the logging levels, object format style, and root logging
    # level.
    #
    def pre_config( config )
      # if no pre_config section was given, just create an empty hash
      # we do this to ensure that some logging levels are always defined
      config ||= Hash.new

      # define levels
      levels = config['define_levels']
      ::Logging.init(levels) unless levels.nil?

      # format as
      format = config['format_as']
      ::Logging.format_as(format) unless format.nil?

      # backtrace
      value = config['backtrace']
      ::Logging.backtrace(value) unless value.nil?

      # grab the root logger and set the logging level
      root = ::Logging::Logger.root
      if config.has_key?('root')
        root.level = config['root']['level']
      end
    end

    # call-seq:
    #    appenders( ary )
    #
    # Given an array of Appender configurations, this method will iterate
    # over each and create the Appender(s).
    #
    def appenders( ary )
      return if ary.nil?

      ary.each {|h| appender(h)}
    end

    # call-seq:
    #    loggers( ary )
    #
    # Given an array of Logger configurations, this method will iterate over
    # each and create the Logger(s).
    #
    def loggers( ary )
      return if ary.nil?

      ary.each do |config|
        name = config['name']
        raise Error, 'Logger name not given' if name.nil?

        l = Logging::Logger.new name
        l.level = config['level'] if config.has_key?('level')
        l.additive = config['additive'] if l.respond_to? :additive=
        l.trace = config['trace'] if l.respond_to? :trace=

        if config.has_key?('appenders')
          l.appenders = config['appenders'].map {|n| ::Logging::Appenders[n]}
        end
      end
    end

    # call-seq:
    #    appender( config )
    #
    # Creates a new Appender based on the given _config_ options (a hash).
    # The type of Appender created is determined by the 'type' option in the
    # config. The remaining config options are passed to the Appender
    # initializer.
    #
    # The config options can also contain a 'layout' option. This should be
    # another set of options used to create a Layout for this Appender.
    #
    def appender( config )
      return if config.nil?
      config = config.dup

      type = config.delete('type')
      raise Error, 'Appender type not given' if type.nil?

      name = config.delete('name')
      raise Error, 'Appender name not given' if name.nil?

      config['layout'] = layout(config.delete('layout'))

      clazz = ::Logging::Appenders.const_get type
      clazz.new(name, config)
    end

    # call-seq:
    #    layout( config )
    #
    # Creates a new Layout based on the given _config_ options (a hash).
    # The type of Layout created is determined by the 'type' option in the
    # config. The remaining config options are passed to the Layout
    # initializer.
    #
    def layout( config )
      return if config.nil?
      config = config.dup

      type = config.delete('type')
      raise Error, 'Layout type not given' if type.nil?

      clazz = ::Logging::Layouts.const_get type
      clazz.new config
    end

  end  # class YamlConfigurator
end  # module Logging::Config

