import copy
from .core import *
from xml.etree import ElementTree as ET


class Feedback:
    def __init__(self, items=None, fixedOrder=False):
        self._feedback = ET.Element("items")
        self._fixedOrder = fixedOrder
        if items != None:
            if isinstance(items, list):
                self._items = items
            else:
                self._items = [items]
        else:
            self._items = []

    def add(self, items):
        if isinstance(items, list):
            self._items.extend(items)
        else:
            self._items.append(items)

    def get(self, index=None, search=None):
        if not index and not search:
            return self._items
        elif index:
            return self._items[index]
        elif search:
            toReturn = []
            for anItem in self._items:
                if search in anItem.get():
                    toReturn.append(anItem)
            return toReturn

    def pop(self, index=None, search=None):
        if not index and not search:
            toReturn = []
            for anItem in self._items:
                i = self._items.index(anItem)
                toReturn.append(self._items.pop(i))
            return toReturn
        if index:
            return self._items.pop(index)
        elif search:
            toReturn = []
            for anItem in self._items:
                if search in anItem.get():
                    i = self._items.index(anItem)
                    removed = self._items.pop(i)
                    toReturn.append(removed)
            return toReturn

    def list(self, item, length):
        for i in range(length):
            copied = copy.copy(item)
            self._items.append(copied)

    def __repr__(self):
        for anItem in self._items:
            itemToAdd = ET.SubElement(self._feedback, "item")

            data = anItem.get()

            for (k, v) in data["attrib"].iteritems():
                if k == "uid" and self._fixedOrder == True:
                    stamp = timestamp() + str(data.get("order", 0))
                    itemToAdd.set("uid", stamp)
                else:
                    itemToAdd.set(k, v)

            for (k, v) in data["content"].iteritems():
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

        return ET.tostring(self._feedback)


class Item:
    def __init__(self, **kwargs):
        self._title = kwargs.pop("title", "")
        self._subtitle = kwargs.pop("subtitle", "")
        if "uid" in kwargs.keys():
            self._uid = bundle() + "." + kwargs.pop("uid")
        else:
            self._uid = bundle()
        if "valid" in kwargs.keys():
            if kwargs["valid"] == True:
                self._valid = "yes"
            elif kwargs["valid"] == False:
                self._valid = "no"
            else:
                self._valid = kwargs["valid"]
            kwargs.pop("valid")
        else:
            self._valid = "no"
        self._autocomplete = kwargs.pop("autocomplete", None)
        self._icon = kwargs.pop("icon", "icon.png")
        self._fileIcon = kwargs.pop("fileIcon", False)
        self._fileType = kwargs.pop("fileType", False)
        self._order = kwargs.pop("order", None)
        self._arg = kwargs.pop("arg", None)
        self._type = kwargs.pop("type", None)
        if len(kwargs):
            self._keywords = kwargs

    def fromDictionary(self, dictionary):
        self._title = dictionary.pop("title", "")
        self._subtitle = dictionary.pop("subtitle", "")
        if "uid" in dictionary.keys():
            self._uid = bundle() + "." + dictionary.pop("uid")
        else:
            self._uid = bundle()
        if "valid" in dictionary.keys():
            if dictionary["valid"] == True:
                self._valid = "yes"
            elif dictionary["valid"] == False:
                self._valid = "no"
            else:
                self._valid = dictionary["valid"]
            dictionary.pop("valid")
        else:
            self._valid = "no"
        self._autocomplete = dictionary.pop("autocomplete", None)
        self._icon = dictionary.pop("icon", "icon.png")
        self._fileIcon = dictionary.pop("fileIcon", False)
        self._fileType = dictionary.pop("fileType", False)
        self._order = dictionary.pop("order", None)
        self._arg = dictionary.pop("arg", None)
        self._type = dictionary.pop("type", None)
        if len(dictionary):
            self._keywords = dictionary
        return self

    def title(self, setTitle=None):
        if setTitle != None:
            self._title = setTitle
        else:
            return self._title

    def subtitle(self, setSubtitle=None):
        if setSubtitle != None:
            self._subtitle = setSubtitle
        else:
            return self._subtitle

    def icon(self, setIcon=None, fileIcon=False, fileType=False):
        if setIcon != None:
            self._icon = setIcon
            self._fileIcon = fileIcon
            self._fileType = fileType
        else:
            return self._icon

    def uid(self, setUID=None):
        if setUID != None:
            self._uid = setUID
        else:
            return self._uid

    def valid(self, setValid=None):
        if setValid != None:
            if setValid == True:
                self._valid = "yes"
            elif setValid == False:
                self._valid == "no"
            else:
                self._valid = setValid
        else:
            return self._valid

    def autocomplete(self, setAutocomplete=None):
        if setAutocomplete != None:
            self._autocomplete = setAutocomplete
        else:
            return self._autocomplete

    def order(self, setOrder=None):
        if setOrder != None:
            self._order = setOrder
        else:
            return self._order

    def type(self, setType=None):
        if setType != None:
            self._type = setType
        else:
            return self._type

    def copy(self):
        return copy.copy(self)

    def get(self):
        content = {
            "title": self._title,
            "subtitle": self._subtitle,
            "icon": self._icon,
            "fileIcon": self._fileIcon,
            "fileType": self._fileType
        }
        attrib = {
            "uid": self._uid,
            "valid": self._valid,
        }
        if self._autocomplete:
            attrib["autocomplete"] = self._autocomplete
        if self._arg:
            attrib["arg"] = self._arg
        if self._type:
            attrib["type"] = self._type

        data = {"attrib": attrib, "content": content}
        if self._order != None:
            data["order"] = self._order

        return data
