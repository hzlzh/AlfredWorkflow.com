require 'logger'
require 'fileutils'

module Alfred

  class LogUI < ::Logger
    attr_reader :logdev

    def initialize(id, to_file=nil)
      if to_file
        @log_file = to_file
        log_dir = File.dirname(log_file)
        FileUtils.mkdir_p log_dir unless File.exists? log_dir
      end

      super log_file, 'weekly'

      @progname = id
      @default_formatter.datetime_format = '%Y-%m-%d %H:%M:%S '
    end

    def log_file
      @log_file ||= File.expand_path("~/Library/Logs/Alfred-Workflow.log")
    end
  end

end

