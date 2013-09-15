# coding: utf-8

require 'osx/cocoa'
OSX.require_framework 'ScriptingBridge'

def available_airplay_devices
  itunes = OSX::SBApplication.applicationWithBundleIdentifier_('com.apple.iTunes')
  return [] unless itunes.isRunning
  itunes.AirPlayDevices.select(&:available)
end
