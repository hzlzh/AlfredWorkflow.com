import subprocess
import os
import plistlib
import json
from xml.etree import ElementTree as ET
from copy import copy


def bundle():
    infoPath = os.path.abspath("./info.plist")
    if os.path.exists(infoPath):
        info = plistlib.readPlist(infoPath)
        try:
            bundleID = info["bundleid"]
        except KeyError:
            raise Exception("Bundle ID not defined or readable from plist.")
    else:
        raise Exception("Bundle ID not defined or readable from plist.")

    return bundleID


def local(join=None):
    localPath = os.path.abspath("./")

    if join:
        localPath = os.path.join(localPath, join)

    return localPath


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


def find(query):
    output = subprocess.check_output(["mdfind", query])
    returnList = output.split("\n")
    return returnList


class Feedback:
    def __init__(self):
        bundleID = bundle()

        self.myResult = ET.Element("items")
        self.defaultItem = {
            "title": "Item",
            "subtitle": bundleID,
            "icon": "icon.png"
        }

    def addValidItem(self, arg, itemDict, uid=""):
        itemToAdd = ET.SubElement(self.myResult, "item")

        args = {"uid": uid, "arg": arg, "valid": "yes", "autocomplete": ""}
        for (k, v) in args.iteritems():
            itemToAdd.set(k, v)

        data = copy(self.defaultItem)
        data.update(itemDict)

        for (k, v) in data.iteritems():
            child = ET.SubElement(itemToAdd, k)
            child.text = v

    def addInvalidItem(self, autocomplete, itemDict, uid=""):
        itemToAdd = ET.SubElement(self.myResult, "item")

        args = {"uid": uid, "arg": "", "valid": "no", "autocomplete": autocomplete}
        for (k, v) in args.iteritems():
            itemToAdd.set(k, v)

        data = copy(self.defaultItem)
        data.update(itemDict)

        for (k, v) in data.iteritems():
            child = ET.SubElement(itemToAdd, k)
            child.text = v

    def addItem(self, argsDict, itemDict):
        itemToAdd = ET.SubElement(self.myResult, "item")

        for (k, v) in argsDict.iteritems():
            itemToAdd.set(k, v)

        for (k, v) in itemDict.iteritems():
            child = ET.SubElement(itemToAdd, k)
            child.text = v

    def __repr__(self):
        return ET.tostring(self.myResult)


class Settings:
    def __init__(self):
        bundleID = bundle()
        self._settingsPath = nonvolatile(bundleID + ".settings.json")
        if not os.path.exists(self._settingsPath):
            blank = {}
            with open(self._settingsPath, "w") as f:
                json.dump(blank, f)
            self._loadedSettings = blank
        else:
            with open(self._settingsPath, "r") as f:
                payload = json.load(f)
            self._loadedSettings = payload

    def set(self, **kwargs):
        for (k, v) in kwargs.iteritems():
            self._loadedSettings[k] = v
        with open(self._settingsPath, "w") as f:
            json.dump(self._loadedSettings, f)

    def get(self, k, default=None):
        try:
            return self._loadedSettings[k]
        except KeyError:
            return default

    def delete(self, k):
        try:
            if k in self._loadedSettings.keys():
                self._loadedSettings.pop(k)
                with open(self._settingsPath, "w") as f:
                    json.dump(self._loadedSettings, f)
        except Exception:
            pass
