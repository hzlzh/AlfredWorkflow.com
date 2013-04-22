require 'logging'

module Alfred

  class Logger
    def initialize(id)
      @id = id
    end

    def info(msg)
      logger.info msg
    end
    def warn(msg)
      logger.warn msg
    end
    def debug(msg)
      logger.debug msg
    end
    def error(msg)
      logger.error msg
    end
    def fatal(msg)
      logger.fatal msg
    end

    def logger
      @logger ||= init_log
    end

    def logger_file
      @logger_file ||= File.expand_path("~/Library/Logs/Alfred-Workflow.log")
    end

    private

    def init_log
      @logger = Logging.logger[@id]
      @logger.level = :debug
      @logger.add_appenders(
        Logging.appenders.file(logger_file)
      )
      @logger
    end
  end


end


