# -*- coding: utf-8 -*-

from xml.etree import ElementTree as ET
import copy
import alp.core as core


class Item(object):
    def __init__(self, **kwargs):
        self.title = kwargs.pop("title", "")
        self.subtitle = kwargs.pop("subtitle", "")
        self.uid = kwargs.pop("uid", None)
        if "valid" in kwargs.keys():
            if kwargs["valid"] == True:
                self.valid = "yes"
            elif kwargs["valid"] == False:
                self.valid = "no"
            else:
                self.valid = kwargs["valid"]
            kwargs.pop("valid")
        else:
            self.valid = None
        self.autocomplete = kwargs.pop("autocomplete", None)
        self.icon = kwargs.pop("icon", "icon.png")
        self.fileIcon = kwargs.pop("fileIcon", False)
        self.fileType = kwargs.pop("fileType", False)
        self.arg = kwargs.pop("arg", None)
        self.type = kwargs.pop("type", None)

    def copy(self):
        return copy.copy(self)

    def get(self):
        content = {
            "title": self.title,
            "subtitle": self.subtitle,
            "icon": self.icon,
            "fileIcon": self.fileIcon,
            "fileType": self.fileType
        }
        attrib = {
            "uid": self.uid,
            "valid": self.valid,
        }
        if self.autocomplete:
            attrib["autocomplete"] = self.autocomplete
        if self.arg:
            if "\n" in self.arg:
                content["arg"] = self.arg
            else:
                attrib["arg"] = self.arg
        if self.type:
            attrib["type"] = self.type

        data = {"attrib": attrib, "content": content}

        return data

def feedback(items):
    feedback = ET.Element("items")
    
    def processItem(item):
        itemToAdd = ET.SubElement(feedback, "item")

        data = item.get()

        for (k, v) in data["attrib"].iteritems():
            if v is None:
                continue
            itemToAdd.set(k, v)

        for (k, v) in data["content"].iteritems():
            if v is None:
                continue
            if k != "fileIcon" and k != "fileType":
                child = ET.SubElement(itemToAdd, k)
                child.text = v
            if k == "icon":
                if "fileIcon" in data["content"].keys():
                    if data["content"]["fileIcon"] == True:
                        child.set("type", "fileicon")
                if "fileType" in data["content"].keys():
                    if data["content"]["fileType"] == True:
                        child.set("type", "filetype")

    if isinstance(items, list):
        for anItem in items:
            processItem(anItem)
    else:
        processItem(items)

    print ET.tostring(feedback, encoding="utf-8")
