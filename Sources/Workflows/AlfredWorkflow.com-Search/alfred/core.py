# -*- coding: utf-8 -*-
import os, sys, plistlib, time, subprocess

from feedback import Feedback
import util

_bundle_id = None
_CONFIG_FOLDER = os.path.expanduser('~/Library/Application Support/Alfred 2/Workflow Data/')
_CACHE_FOLDER = os.path.expanduser('~/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/')

def bundleID():
    global _bundle_id
    if _bundle_id:
        return _bundle_id
    try:
        plist_path = os.path.abspath('./info.plist')
        pref = plistlib.readPlist(plist_path)
        _bundle_id = pref.get('bundleid', '')
        name = pref.get('name', '')
        if not _bundle_id and name:
            name_hash = util.hashDigest(name)
            _bundle_id = 'com.alfredapp.workflow.{}'.format(name_hash)
    except:
        pass
    if not _bundle_id:
        _bundle_id = 'com.alfredapp.workflow.BoudleIDMissing'
    return _bundle_id

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
    retcode = kwargs.pop('retcode', 0)
    fb = Feedback()
    fb.addItem(**kwargs)
    fb.output()
    sys.exit(retcode)

def exit(msg='', retcode=0):
    if msg:
        print(msg)
    sys.exit(retcode)
    
def show(query):
    subprocess.call(
        'osascript -e "tell application \\"Alfred 2\\" to search \\"' + query + '\\""',
        shell=True
    )

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
    
