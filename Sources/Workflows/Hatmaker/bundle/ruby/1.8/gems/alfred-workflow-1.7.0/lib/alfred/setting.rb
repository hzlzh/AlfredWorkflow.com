require 'yaml'
require 'plist'

module Alfred

  class Setting
    attr_accessor :settings

    def initialize(alfred, &blk)
      @core = alfred
      instance_eval(&blk) if block_given?
      raise InvalidFormat, "#{format} is not suported." unless validate_format
      @backend = get_format_class(format).new(@core, setting_file)
    end

    def use_setting_file(opts = {})
      @setting_file = opts[:file] if opts[:file]
      @format = opts[:format] ? opts[:format] : "yaml"
    end


    def validate_format
      ['yaml', 'plist'].include?(format)
    end

    def format
      @format ||= "yaml"
    end

    def setting_file
      @setting_file ||= File.join(@core.storage_path, "setting.#{@format}")
    end

    def get_format_class(format_class)
      Alfred::Setting.const_get("#{format.to_s.capitalize}End")
    end

    def load
      @backend.send(:load)
    end

    def dump(settings = nil, opts = {})
      @backend.send(:dump, settings, opts)
    end

    class YamlEnd
      attr_reader :setting_file
      def initialize(alfred, file)
        @core = alfred
        @setting_file = file
      end

      def load
        unless File.exist?(setting_file)
          @settings = {:id => @core.bundle_id}
          dump
        end

        @settings = YAML::load( File.read(setting_file) )
      end

      def dump(settings = nil, opts = {})
        settings = @settings unless settings

        File.open(setting_file, "wb") { |f|
          YAML::dump(settings, f)
          f.flush if opts[:flush]
        }
      end
    end

    class PlistEnd
      attr_reader :setting_file
      def initialize(alfred, file)
        @core = alfred
        @setting_file = file
      end

      def load
        unless File.exist?(setting_file)
          @settings = {:id => @core.bundle_id}
          dump
        end

        @settings = Plist::parse_xml( File.read(setting_file) )
      end

      def dump(settings = nil, opts = {})
        settings = @settings unless settings

        File.open(setting_file, "wb") { |f|
          f.puts settings.to_plist
          f.flush if opts[:flush]
        }
      end
    end


  end
end


