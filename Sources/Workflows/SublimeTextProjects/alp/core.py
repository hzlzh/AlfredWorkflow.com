# -*- coding: utf-8 -*-

import json
import time
import subprocess
import os
import sys
import plistlib
import unicodedata
import codecs


def bundle():
    infoPath = os.path.abspath("./info.plist")
    if os.path.exists(infoPath):
        info = plistlib.readPlist(infoPath)
        try:
            bundleID = info["bundleid"]
        except KeyError:
            raise Exception("Bundle ID not defined or readable from info.plist.")
    else:
        raise Exception("info.plist missing.")

    return bundleID


def args():
    # With thanks to Github's nikipore for the pointer re. unicodedata.
    returnList = []
    for arg in sys.argv[1:]:
        returnList.append(decode(arg))
    return returnList


def decode(s):
    return unicodedata.normalize("NFC", s.decode("utf-8"))


def timestamp(format=None):
    if format:
        return time.strftime(format)
    else:
        return time.strftime("%Y-%m-%d-%H:%M:%S")


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
    if os.path.isabs(path):
        return plistlib.readPlist(path)
    else:
        return plistlib.readPlist(storage(path))


def writePlist(obj, path):
    if os.path.isabs(path):
        plistlib.writePlist(obj, path)
    else:
        plistlib.writePlist(obj, storage(path))


def jsonLoad(path):
    if not os.path.isabs(path):
        path = storage(path)

    if os.path.exists(path):
        with codecs.open(path, "r", "utf-8") as f:
            read = json.load(f)
        return read
    else:
        blank = {}
        with codecs.open(path, "w", "utf-8") as f:
            json.dump(blank, f)
        return blank


def jsonDump(obj, path):
    if not os.path.isabs(path):
        path = storage(path)

    with codecs.open(path, "w", "utf-8") as f:
        json.dump(obj, f)


def find(query):
    qString = "mdfind %s" % query
    output = subprocess.check_output(qString, shell=True)
    returnList = output.split("\n")
    if returnList[-1] == "":
        returnList = returnList[:-1]
    return returnList

def log(s):
    log_text = "[%s: %s (%s)]\n" % (bundle(), s, timestamp())
    if not os.path.exists(local("debug.log")):
        with open(local("debug.log"), "w") as f:
            f.write("\n")
    with codecs.open(local("debug.log"), "a", "utf-8") as f:
        f.write(decode(log_text))
