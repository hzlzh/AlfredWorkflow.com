# Python integration with Mountain Lion's notification center

import Foundation, objc

NSUserNotification = objc.lookUpClass('NSUserNotification')
NSUserNotificationCenter = objc.lookUpClass('NSUserNotificationCenter')


def notify(title, subtitle, info_text, delay=0, sound=False, userInfo={}):
	""" Python method to show a desktop notification on Mountain Lion. Where:
			title: Title of notification
			subtitle: Subtitle of notification
			info_text: Informative text of notification
			delay: Delay (in seconds) before showing the notification
			sound: Play the default notification sound
			userInfo: a dictionary that can be used to handle clicks in your
					  app's applicationDidFinishLaunching:aNotification method
	  """
	notification = NSUserNotification.alloc().init()
	notification.setTitle_(title)
	notification.setSubtitle_(subtitle)
	notification.setInformativeText_(info_text)
	notification.setUserInfo_(userInfo)
	if sound:
		notification.setSoundName_("NSUserNotificationDefaultSoundName")
	notification.setDeliveryDate_(Foundation.NSDate.dateWithTimeInterval_sinceDate_(delay, Foundation.NSDate.date()))
	def applicationDidFinishLaunching_(self, sender):
		# check if the application launch sender's userInfo
		userInfo = sender.userInfo()
		if userInfo["action"] == "open_url":
			print '123123123'
	NSUserNotificationCenter.defaultUserNotificationCenter().scheduleNotification_(notification)