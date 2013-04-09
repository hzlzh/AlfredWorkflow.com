# -*- coding: utf-8 -*-
import os, sys, plistlib, time

from feedback import Feedback

BundleID = None

def bundleID():
    global BundleID
    if BundleID:
        return BundleID
    path = os.path.abspath('./info.plist')
    try:
        info = plistlib.readPlist(path)
        BundleID = info['bundleid']
    except Exception, e:
        raise Exception('get Bundle ID fail. {}'.format(e))
    return BundleID

def log(s):
    log_text = '[{} {}]: {}\n'.format(bundleID(), time.strftime('%Y-%m-%d %H:%M:%S'), s)
    log_file = os.path.abspath('./log.txt')
    if not os.path.exists(log_file):
        with open(log_file, 'w') as f:
            f.write(log_text)
    else:
        with open(log_file, 'a') as f:
            f.write(log_text)

def argv(pos, default=None):
    try:
        arg = sys.argv[pos]
    except:
        return default
    return arg

def exitWithFeedback(**kwargs):
    fb = Feedback()
    fb.addItem(**kwargs)
    fb.output()
    sys.exit(0)

def exit(msg = ''):
    if msg:
        print(msg)
    sys.exit(0)

def notify(title, subtitle, text='', sound=True):
    try:
        import objc, AppKit
        app = AppKit.NSApplication.sharedApplication()
        NSUserNotification = objc.lookUpClass("NSUserNotification")
        NSUserNotificationCenter = objc.lookUpClass("NSUserNotificationCenter")
        notification = NSUserNotification.alloc().init()
        notification.setTitle_(title)
        notification.setSubtitle_(subtitle)
        notification.setInformativeText_(text)
        if sound:
            notification.setSoundName_("NSUserNotificationDefaultSoundName")
        NSUserNotificationCenter.defaultUserNotificationCenter().scheduleNotification_(notification)
    except Exception, e:
        log('Notification failed. {}'.format(e))
    