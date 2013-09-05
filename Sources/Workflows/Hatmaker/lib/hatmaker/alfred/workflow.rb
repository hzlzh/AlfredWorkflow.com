class Hatmaker::Alfred::Workflow
  attr_reader :author, :bundle_id, :description, :name

  def initialize(folder_name)
    @folder_name  = folder_name

    @author       = info['createdby']
    @bundle_id    = info['bundleid']
    @description  = info['description']
    @disabled     = info['disabled']
    @name         = info['name']
  end

  def last_release
    @last_release ||= Hatmaker::Workflow.find self
  end

  def outdated?
    last_release && last_release.version > version
  end

  def path
    "#{Hatmaker::Alfred::WORKFLOWS_PATH}/#{@folder_name}"
  end

  def storage_path
    "#{Hatmaker::Alfred::STORAGE_PATH}/#{@bundle_id}"
  end

  def version
    @version ||= (Hatmaker.setting[@name] || alleyoop['version']).to_f
  end

  def self.all
    Dir.foreach(Hatmaker::Alfred::WORKFLOWS_PATH).map do |folder_name|
      next if folder_name =~ /^\./ or folder_name == 'hatmaker'
      new folder_name
    end.compact
  end

  private

  def alleyoop
    @alleyoop ||= Oj.parse(File.read("#{path}/update.json")) rescue {}
  end

  def info
    @info ||= Plist::parse_xml(File.read("#{path}/info.plist"))
  end
end
