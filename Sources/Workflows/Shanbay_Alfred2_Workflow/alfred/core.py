# -*- coding: utf-8 -*-
import os, plistlib, time

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