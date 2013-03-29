import threading
import objc
from Foundation import *
from AppKit import *
from PyObjCTools import AppHelper
import platform
import alp.core as core


NSUserNotificationActivationTypeNone = 0
NSUserNotificationActivationTypeContentsClicked = 1
NSUserNotificationActivationTypeActionButtonClicked = 2


class Notification(object):
    def notify(self, title, subtitle, text, info=None):
        v, _, _ = platform.mac_ver()
        v = float('.'.join(v.split('.')[:2]))
        if v < 10.8:
            core.log("Notification failed: OS version %s < 10.8." % v)
            return

        app = NSApplication.sharedApplication()

        NSUserNotification = objc.lookUpClass("NSUserNotification")
        NSUserNotificationCenter = objc.lookUpClass("NSUserNotificationCenter")
        notification = NSUserNotification.alloc().init()

        notification.setTitle_(title)
        notification.setSubtitle_(subtitle)
        notification.setInformativeText_(text)
        notification.setSoundName_("NSUserNotificationDefaultSoundName")
        notification.setUserInfo_(info)

        app.setDelegate_(self)
        NSUserNotificationCenter.defaultUserNotificationCenter().setDelegate_(self)
        NSUserNotificationCenter.defaultUserNotificationCenter().scheduleNotification_(notification)
