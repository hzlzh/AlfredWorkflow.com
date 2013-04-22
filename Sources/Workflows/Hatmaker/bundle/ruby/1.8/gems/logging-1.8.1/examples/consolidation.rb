# :stopdoc:
#
# Logging support can be included globally giving all objects in the Ruby
# space access to a logger instance. This "logger" method invokes
#
#    Logging.logger[self]
#
# And returns the appropriate logger for the current context.
#
# However, there might be times when it is not desirable to create an
# individual logger for every class and module. This is where the concept of
# "logger consolidation" comes into play. A ruby namespace can be configured
# to consolidate loggers such that all classes and modules in that namespace
# use the same logger instance.
#
# Because our loggers are being accessed via the self context, it becomes
# very easy to turn on debugging on a class-by-class basis (or a
# module-by-module basis). The trick is to create the debug logger first and
# then configure the namespace to consolidate all loggers. Since we already
# created our debug logger, it will be used by the class in question instead
# of the consolidated namespace logger.
#

  require 'logging'
  include Logging.globally

  Logging.logger.root.appenders = Logging.appenders.stdout
  Logging.logger.root.level = :info

  # we want to debug the "FooBar" module of ActiveRecord
  Logging.logger['ActiveRecord::FooBar'].level = :debug

  # and we want everything else in ActiveRecord and ActiveResource
  # to use the same consolidated loggers (one for each namespace)
  Logging.consolidate 'ActiveRecord', 'ActiveResource'


  logger.info 'because we included Logging globally, ' \
              'we have access to a logger anywhere in our code'


  module ActiveRecord
    logger.info 'even at the module level'

    class Base
      logger.info 'and at the class level'
    end
  end


  module ActiveResource
    logger.info "you'll notice that these log messages " \
                "are coming from the same logger"

    class Base
      logger.info "even though the logger is invoked from different classes"
    end

    class Foo
      def foo
        logger.info "that is because ActiveRecord and ActiveResource " \
                    "are consolidating loggers in their respective namespaces"
      end
    end
    Foo.new.foo
  end


  module ActiveRecord
    logger.debug 'this debug message will not be logged ' \
                 '- level is info'

    class Base
      logger.debug 'and this debug message will not be logged either ' \
                   '- same logger as above'
    end

    module FooBar
      logger.debug 'however, this debug message WILL be logged'
    end
  end

# :startdoc:
