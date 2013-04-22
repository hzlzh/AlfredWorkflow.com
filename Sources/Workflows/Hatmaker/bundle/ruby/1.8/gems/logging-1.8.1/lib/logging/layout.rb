
module Logging

# The +Layout+ class provides methods for formatting log events into a
# string representation. Layouts are used by Appenders to format log
# events before writing them to the logging destination.
#
# All other Layouts inherit from this class which provides stub methods.
# Each subclass should provide a +format+ method. A layout can be used by
# more than one +Appender+ so all the methods need to be thread safe.
#
class Layout

  # call-seq:
  #    Layout.new( :format_as => :string )
  #
  # Creates a new layout that will format objects as strings using the
  # given <tt>:format_as</tt> style. This can be one of <tt>:string</tt>,
  # <tt>:inspect</tt>, or <tt>:yaml</tt>. These formatting commands map to
  # the following object methods:
  #
  # * :string  => to_s
  # * :inspect => inspect
  # * :yaml    => to_yaml
  # * :json    => MultiJson.encode(obj)
  #
  # If the format is not specified then the global object format is used
  # (see Logging#format_as). If the global object format is not specified
  # then <tt>:string</tt> is used.
  #
  def initialize( opts = {} )
    ::Logging.init unless ::Logging.initialized?

    default = ::Logging.const_defined?('OBJ_FORMAT') ?
              ::Logging::OBJ_FORMAT : nil

    f = opts.getopt(:format_as, default)
    f = f.intern if f.instance_of? String

    @obj_format = case f
                  when :inspect, :yaml, :json; f
                  else :string end

    b = opts.getopt(:backtrace, ::Logging.backtrace)
    @backtrace = case b
        when :on, 'on', true;    true
        when :off, 'off', false; false
        else
          raise ArgumentError, "backtrace must be true or false"
        end
  end

  # call-seq:
  #    format( event )
  #
  # Returns a string representation of the given logging _event_. It is
  # up to subclasses to implement this method.
  #
  def format( event ) nil end

  # call-seq:
  #    header
  #
  # Returns a header string to be used at the beginning of a logging
  # appender.
  #
  def header( ) '' end

  # call-seq:
  #    footer
  #
  # Returns a footer string to be used at the end of a logging appender.
  #
  def footer( ) '' end

  # call-seq:
  #    format_obj( obj )
  #
  # Return a string representation of the given object. Depending upon
  # the configuration of the logger system the format will be an +inspect+
  # based representation or a +yaml+ based representation.
  #
  def format_obj( obj )
    case obj
    when String; obj
    when Exception
      str = "<#{obj.class.name}> #{obj.message}"
      if @backtrace && !obj.backtrace.nil?
        str << "\n\t" << obj.backtrace.join("\n\t")
      end
      str
    when nil; "<#{obj.class.name}> nil"
    else
      str = "<#{obj.class.name}> "
      str << case @obj_format
             when :inspect; obj.inspect
             when :yaml; try_yaml(obj)
             when :json; try_json(obj)
             else obj.to_s end
      str
    end
  end

  # Attempt to format the _obj_ using yaml, but fall back to inspect style
  # formatting if yaml fails.
  #
  # obj - The Object to format.
  #
  # Returns a String representation of the object.
  #
  def try_yaml( obj )
    "\n#{obj.to_yaml}"
  rescue TypeError
    obj.inspect
  end

  # Attempt to format the given object as a JSON string, but fall back to
  # inspect formatting if JSON encoding fails.
  #
  # obj - The Object to format.
  #
  # Returns a String representation of the object.
  #
  def try_json( obj )
    MultiJson.encode(obj)
  rescue StandardError
    obj.inspect
  end

end  # class Layout
end  # module Logging

