
module Logging

  # A Mapped Diagnostic Context, or MDC in short, is an instrument used to
  # distinguish interleaved log output from different sources. Log output is
  # typically interleaved when a server handles multiple clients
  # near-simultaneously.
  #
  # Interleaved log output can still be meaningful if each log entry from
  # different contexts had a distinctive stamp. This is where MDCs come into
  # play.
  #
  # The MDC provides a hash of contextual messages that are identified by
  # unique keys. These unique keys are set by the application and appended
  # to log messages to identify groups of log events. One use of the Mapped
  # Diagnostic Context is to store HTTP request headers associated with a Rack
  # request. These headers can be included with all log messages emitted while
  # generating the HTTP response.
  #
  # When configured to do so, PatternLayout instances will automatically
  # retrieve the mapped diagnostic context for the current thread with out any
  # user intervention. This context information can be used to track user
  # sessions in a Rails application, for example.
  #
  # Note that MDCs are managed on a per thread basis. MDC operations such as
  # `[]`, `[]=`, and `clear` affect the MDC of the current thread only. MDCs
  # of other threads remain unaffected.
  #
  # By default, when a new thread is created it will inherit the context of
  # its parent thread. However, the `inherit` method may be used to inherit
  # context for any other thread in the application.
  #
  module MappedDiagnosticContext
    extend self

    # The name used to retrieve the MDC from thread-local storage.
    NAME = 'logging.mapped-diagnostic-context'.freeze

    # Public: Put a context value as identified with the key parameter into
    # the current thread's context map.
    #
    # key   - The String identifier for the context.
    # value - The String value to store.
    #
    # Returns the value.
    #
    def []=( key, value )
      context.store(key.to_s, value)
    end

    # Public: Get the context value identified with the key parameter.
    #
    # key - The String identifier for the context.
    #
    # Returns the value associated with the key or nil if there is no value
    # present.
    #
    def []( key )
      context.fetch(key.to_s, nil)
    end

    # Public: Remove the context value identified with the key parameter.
    #
    # key - The String identifier for the context.
    #
    # Returns the value associated with the key or nil if there is no value
    # present.
    #
    def delete( key )
      context.delete(key.to_s)
    end

    # Public: Clear all mapped diagnostic information if any. This method is
    # useful in cases where the same thread can be potentially used over and
    # over in different unrelated contexts.
    #
    # Returns the MappedDiagnosticContext.
    #
    def clear
      context.clear if Thread.current[NAME]
      self
    end

    # Public: Inherit the diagnostic context of another thread. In the vast
    # majority of cases the other thread will the parent that spawned the
    # current thread. The diagnostic context from the parent thread is cloned
    # before being inherited; the two diagnostic contexts can be changed
    # independently.
    #
    # Returns the MappedDiagnosticContext.
    #
    def inherit( obj )
      case obj
      when Hash
        Thread.current[NAME] = obj.dup
      when Thread
        return if Thread.current == obj
        Thread.exclusive {
          Thread.current[NAME] = obj[NAME].dup if obj[NAME]
        }
      end

      self
    end

    # Returns the Hash acting as the storage for this NestedDiagnosticContext.
    # A new storage Hash is created for each Thread running in the
    # application.
    #
    def context
      Thread.current[NAME] ||= Hash.new
    end
  end  # MappedDiagnosticContext


  # A Nested Diagnostic Context, or NDC in short, is an instrument to
  # distinguish interleaved log output from different sources. Log output is
  # typically interleaved when a server handles multiple clients
  # near-simultaneously.
  #
  # Interleaved log output can still be meaningful if each log entry from
  # different contexts had a distinctive stamp. This is where NDCs come into
  # play.
  #
  # The NDC is a stack of contextual messages that are pushed and popped by
  # the client as different contexts are encountered in the application. When a
  # new context is entered, the client will `push` a new message onto the NDC
  # stack. This message appears in all log messages. When this context is
  # exited, the client will call `pop` to remove the message.
  #
  # * Contexts can be nested
  # * When entering a context, call `Logging.ndc.push`
  # * When leaving a context, call `Logging.ndc.pop`
  # * Configure the PatternLayout to log context information
  #
  # There is no penalty for forgetting to match each push operation with a
  # corresponding pop, except the obvious mismatch between the real
  # application context and the context set in the NDC.
  #
  # When configured to do so, PatternLayout instance will automatically
  # retrieve the nested diagnostic context for the current thread with out any
  # user intervention. This context information can be used to track user
  # sessions in a Rails application, for example.
  #
  # Note that NDCs are managed on a per thread basis. NDC operations such as
  # `push`, `pop`, and `clear` affect the NDC of the current thread only. NDCs
  # of other threads remain unaffected.
  #
  # By default, when a new thread is created it will inherit the context of
  # its parent thread. However, the `inherit` method may be used to inherit
  # context for any other thread in the application.
  #
  module NestedDiagnosticContext
    extend self

    # The name used to retrieve the NDC from thread-local storage.
    NAME = 'logging.nested-diagnostic-context'.freeze

    # Public: Push new diagnostic context information for the current thread.
    # The contents of the message parameter is determined solely by the
    # client.
    #
    # message - The message String to add to the current context.
    #
    # Returns the current NestedDiagnosticContext.
    #
    def push( message )
      context.push(message)
      self
    end
    alias :<< :push

    # Public: Clients should call this method before leaving a diagnostic
    # context. The returned value is the last pushed message. If no
    # context is available then `nil` is returned.
    #
    # Returns the last pushed diagnostic message String or nil if no messages
    # exist.
    #
    def pop
      context.pop
    end

    # Public: Looks at the last diagnostic context at the top of this NDC
    # without removing it. The returned value is the last pushed message. If
    # no context is available then `nil` is returned.
    #
    # Returns the last pushed diagnostic message String or nil if no messages
    # exist.
    #
    def peek
      context.last
    end

    # Public: Clear all nested diagnostic information if any. This method is
    # useful in cases where the same thread can be potentially used over and
    # over in different unrelated contexts.
    #
    # Returns the NestedDiagnosticContext.
    #
    def clear
      context.clear if Thread.current[NAME]
      self
    end

    # Public: Inherit the diagnostic context of another thread. In the vast
    # majority of cases the other thread will the parent that spawned the
    # current thread. The diagnostic context from the parent thread is cloned
    # before being inherited; the two diagnostic contexts can be changed
    # independently.
    #
    # Returns the NestedDiagnosticContext.
    #
    def inherit( obj )
      case obj
      when Array
        Thread.current[NAME] = obj.dup
      when Thread
        return if Thread.current == obj
        Thread.exclusive {
          Thread.current[NAME] = obj[NAME].dup if obj[NAME]
        }
      end

      self
    end

    # Returns the Array acting as the storage stack for this
    # NestedDiagnosticContext. A new storage Array is created for each Thread
    # running in the application.
    #
    def context
      Thread.current[NAME] ||= Array.new
    end
  end  # NestedDiagnosticContext


  # Public: Accessor method for getting the current Thread's
  # MappedDiagnosticContext.
  #
  # Returns MappedDiagnosticContext
  #
  def self.mdc() MappedDiagnosticContext end

  # Public: Accessor method for getting the current Thread's
  # NestedDiagnosticContext.
  #
  # Returns NestedDiagnosticContext
  #
  def self.ndc() NestedDiagnosticContext end

  # Public: Convenience method that will clear both the Mapped Diagnostic
  # Context and the Nested Diagnostic Context of the current thread. If the
  # `all` flag passed to this method is true, then the diagnostic contexts for
  # _every_ thread in the application will be cleared.
  #
  # all - Boolean flag used to clear the context of every Thread (default is false)
  #
  # Returns the Logging module.
  #
  def self.clear_diagnostic_contexts( all = false )
    if all
      Thread.exclusive {
        Thread.list.each { |thread|
          thread[MappedDiagnosticContext::NAME].clear if thread[MappedDiagnosticContext::NAME]
          thread[NestedDiagnosticContext::NAME].clear if thread[NestedDiagnosticContext::NAME]
        }
      }
    else
      MappedDiagnosticContext.clear
      NestedDiagnosticContext.clear
    end

    self
  end

end  # module Logging


# :stopdoc:
class Thread
  class << self

    %w[new start fork].each do |m|
      class_eval <<-__, __FILE__, __LINE__
        alias :_orig_#{m} :#{m}
        private :_orig_#{m}
        def #{m}( *a, &b )
          create_with_logging_context(:_orig_#{m}, *a ,&b)
        end
      __
    end

  private

    # In order for the diagnostic contexts to behave properly we need to
    # inherit state from the parent thread. The only way I have found to do
    # this in Ruby is to override `new` and capture the contexts from the
    # parent Thread at the time the child Thread is created. The code below does
    # just this. If there is a more idiomatic way of accomplishing this in Ruby,
    # please let me know!
    #
    # Also, great care is taken in this code to ensure that a reference to the
    # parent thread does not exist in the binding associated with the block
    # being executed in the child thread. The same is true for the parent
    # thread's mdc and ndc. If any of those references end up in the binding,
    # then they cannot be garbage collected until the child thread exits.
    #
    def create_with_logging_context( m, *a, &b )
      mdc, ndc = nil

      if Thread.current[Logging::MappedDiagnosticContext::NAME]
        mdc = Thread.current[Logging::MappedDiagnosticContext::NAME].dup
      end

      if Thread.current[Logging::NestedDiagnosticContext::NAME]
        ndc = Thread.current[Logging::NestedDiagnosticContext::NAME].dup
      end

      self.send(m, *a) { |*args|
        Logging::MappedDiagnosticContext.inherit(mdc)
        Logging::NestedDiagnosticContext.inherit(ndc)
        b.call(*args)
      }
    end

  end
end  # Thread
# :startdoc:

