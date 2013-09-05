module Hatmaker
  BUNDLE_ID = 'com.github.bpinto.hatmaker'

  def self.setting
    Hatmaker::Alfred::YamlEnd.load("#{storage_path}/setting.yaml")
  end

  private

  def self.path
    workflow.path
  end

  def self.storage_path
    workflow.storage_path
  end

  def self.workflow
    @workflow ||= Hatmaker::Alfred::Workflow.all.find { |workflow| workflow.bundle_id == BUNDLE_ID }
  end
end
