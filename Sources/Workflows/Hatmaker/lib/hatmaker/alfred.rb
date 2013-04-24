class Hatmaker::Alfred
  STORAGE_PATH   = "#{ENV['HOME']}/Library/Application Support/Alfred 2/Workflow Data"
  WORKFLOWS_PATH = File.join(File.dirname(__FILE__), '../../../..')

  def self.info(msg)
    logger.info msg.to_s
  end

  def self.error(msg)
    logger.error msg.to_s
  end

  private

  def self.logger
    @logger ||= Alfred::Logger.new(100) #TODO: remove this pog
  end
end
