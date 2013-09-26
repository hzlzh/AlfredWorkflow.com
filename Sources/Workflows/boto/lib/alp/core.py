# -*- coding: utf-8 -*-

import json
import time
import subprocess
import os
import sys
import plistlib
import unicodedata
import codecs
from .core_dependencies import six
from .core_dependencies import biplist


gBundleID = None


def bundle():
    global gBundleID

    if gBundleID is not None:
        return gBundleID

    infoPath = os.path.abspath("./info.plist")
    if os.path.exists(infoPath):
        info = plistlib.readPlist(infoPath)
        try:
            gBundleID = info["bundleid"]
        except KeyError:
            raise Exception("Bundle ID not defined or readable from info.plist.")
    else:
        raise Exception("info.plist missing.")

    return gBundleID


def args():
    # With thanks to Github's nikipore for the pointer re. unicodedata.
    returnList = []
    for arg in sys.argv[1:]:
        returnList.append(decode(arg))
    return returnList


def decode(s):
    return unicodedata.normalize("NFC", s.decode("utf-8"))


def local(join=None):
    localPath = os.path.abspath("./")

    if join:
        localPath = os.path.join(localPath, join)

    return localPath


def cache(join=None):
    bundleID = bundle()
    vPath = os.path.expanduser(os.path.join("~/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/", bundleID))

    if not os.path.exists(vPath):
        os.makedirs(vPath)

    if join:
        vPath = os.path.join(vPath, join)

    return vPath


def storage(join=None):
    bundleID = bundle()
    nvPath = os.path.expanduser(os.path.join("~/Library/Application Support/Alfred 2/Workflow Data/", bundleID))

    if not os.path.exists(nvPath):
        os.makedirs(nvPath)

    if join:
        nvPath = os.path.join(nvPath, join)

    return nvPath


def readPlist(path):
    # With thanks to https://github.com/congalong for solving the biplist problem
    if not os.path.isabs(path):
        path = storage(path)
    
    if not isinstance(path, six.binary_type):
        with codecs.open(path, "r", "utf-8") as f:
            s = f.read()
        return plistlib.readPlistFromString(s)
    else:
        return biplist.readPlist(path)


def writePlist(obj, path):
    if not os.path.isabs(path):
        path = storage(path)
    
    s = plistlib.writePlistToString(obj)
    with codecs.open(path, "w", "utf-8") as f:
        f.write(s)


def jsonLoad(path, default=None):
    if not os.path.isabs(path):
        path = storage(path)

    if os.path.exists(path):
        with codecs.open(path, "r", "utf-8") as f:
            read = json.load(f)
        return read
    elif default != None:
        with codecs.open(path, "w", "utf-8") as f:
            json.dump(default, f)
        return default
    else:
        with codecs.open(path, "w", "utf-8") as f:
            f.write("\n")
        return None


def jsonDump(obj, path):
    if not os.path.isabs(path):
        path = storage(path)

    with codecs.open(path, "w", "utf-8") as f:
        json.dump(obj, f)


def find(query):
    qString = "mdfind {0}".format(query)
    output = subprocess.check_output(qString, shell=True)
    returnList = output.split("\n")
    if returnList[-1] == "":
        returnList = returnList[:-1]
    return returnList


def log(s):
    log_text = "[{0}: {1} ({2})]\n".format(bundle(), s, time.strftime("%Y-%m-%d-%H:%M:%S"))
    if not os.path.exists(local("debug.log")):
        with open(local("debug.log"), "w") as f:
            f.write("\n")
    with codecs.open(local("debug.log"), "a", "utf-8") as f:
        f.write(decode(log_text))
