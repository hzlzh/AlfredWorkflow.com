import time
import subprocess
import os
import plistlib


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


def local(join=None):
    localPath = os.path.abspath("./")

    if join:
        localPath = os.path.join(localPath, join)

    return localPath


def timestamp(format=None):
    if format:
        return time.strftime(format)
    else:
        return time.strftime("%Y-%m-%d-%H%M%S%Z")


def volatile(join=None):
    bundleID = bundle()
    vPath = os.path.expanduser(os.path.join("~/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/", bundleID))

    if not os.path.exists(vPath):
        os.makedirs(vPath)

    if join:
        vPath = os.path.join(vPath, join)

    return vPath


def nonvolatile(join=None):
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
        return plistlib.readPlist(nonvolatile(path))


def writePlist(obj, path):
    if os.path.isabs(path):
        plistlib.writePlist(obj, path)
    else:
        plistlib.writePlist(obj, nonvolatile(path))


def find(query):
    output = subprocess.check_output(["mdfind", query])
    returnList = output.split("\n")
    return returnList
