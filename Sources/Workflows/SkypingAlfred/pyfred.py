#!/usr/bin/python
# -*- coding: utf8 -*-
"""
Name: 		    PyFred
Description: 	This Python class object provides several useful functions for retrieving, parsing,
				and formatting data to be used with Alfred 2 Workflows.
				Based on the PHP class Workflows by David Ferguson
Author: 		Rafael Hostettler (@rhostettler)
License:        CC BY-SA 3.0
Revised: 		23/3/2013
Version:		0.1.1
Todo:           - Implement non-blocking queries
Changelog:      2013/3/23 - 0.1 - Initial Release
                2013/2/23 - 0.11 - Error Handling adaptions.
"""

import pickle
import os
import sys
import cgi
from HTMLParser import HTMLParser

class PyFred:
    _xmlpre = "<?xml version=\"1.0\"?><items>"
    _xmlpost ="</items>"
    _items = []

    def __init__(self, uid, restore=True):
        self.uid = uid
        if (restore and os.path.exists(uid + ".pcl")):
            self._items = self._restoreItems()

    def addItem(self,uid,arg,title,subtitle="",valid=True,autocomplete=None,icon=None,icontype=None):
        """
        Adds an item for Alfred's response
        :param uid: The items ID alfred uses for frequency aggregation of the item, make it unique and persistent
        :param arg: What is returned in {query} if the item is selected
        :param title: The large text of the item
        :param subtitle: The subtext of the item
        :param valid: If false, the icon entry cannot be submitted by pressing enter
        :param autocomplete: If set, will put this value instead of current arg in {query}
        :param icon: Icon
        :param icontype: Set to "fileicon" to use an Icon from a file (e.g. in /Application) or
                         "filetype" to use default filetype icon
        """
        self._items.append(AlfredItem(uid,arg,title,subtitle,valid,autocomplete,icon,icontype))
        return self

    def removeItem(self,uid):
        """
        Removes all Items with uid=uid from the list.
        :param uid:
        """
        self._items = filter(lambda f:f.uid!=uid,self._items)
        return self

    def clearStore(self):
        """
        Deletes the file storing the item information
        """
        os.remove(self.uid+".pcl")
        self.items = []

    def toXML(self):
        """
        Returns the all items in one XML ready for Alfred
        :return: XML string
        """
        return self._xmlpre+"\n".join(map(lambda f:f.toXML(),self._items))+self._xmlpost

    def storeAndReturnXML(self):
        """
        Writes the items to disk so they can be reloaded upon instantiation with the same ID
        then returns the items as an XML
        :return: XML string
        """
        self._storeItems()
        return self.toXML()

    def _storeItems(self):
        if(len(self._items) > 0):
            with open(self.uid + ".pcl", 'w') as f:
                pickle.dump(self._items, f)

    def _restoreItems(self):
        try:
            with open(self.uid + ".pcl", 'r') as f:
                return pickle.load(f)
        except (EOFError,IOError):
            os.remove(self.uid+".pcl")


    @staticmethod
    def GenericError(msg=""):
        raise
        return PyFred("ch.xtin.pyfred.error",False). \
            addItem("pyfred_error","pyfred_error","Whoops, some unexpected Error. Please report! Thank you",
                    cgi.escape(msg if msg!="" else "".join(map(str,sys.exc_info()))),False).toXML()

    #Solution for Tag Stripping: http://stackoverflow.com/questions/753052/strip-html-from-strings-in-python
    class MLStripper(HTMLParser):
        def __init__(self):
            self.reset()
            self.fed = []
        def handle_data(self, d):
            self.fed.append(d)
        def get_data(self):
            return ''.join(self.fed)
    @staticmethod
    def stripTags(self,html):
        s = self.MLStripper()
        s.feed(html)
        return s.get_data()

class AlfredItem:

    def __init__(self,uid,arg,title,subtitle="",valid=True,autocomplete=None,icon=None,icontype=None):
        """
        An Item for Alfred's response
        :param uid: The ID, alfred uses for frequency aggregation of the item, make it unique
        :param arg: What is returned in {query} if the item is selected
        :param title: The large text of the item
        :param subtitle: The subtext of the item
        :param valid: If false, the icon entry cannot be submitted by pressing enter
        :param autocomplete: If set, will put this value instead of current arg in {query}
        :param icon: Icon
        :param icontype: Set to "fileicon" to use Icon from /Application or "filetype" to use default folder icon
        """
        self.uid = self._sanitizeStringForXML(uid)
        self.arg = self._sanitizeStringForXML(arg)
        self.title=self._sanitizeStringForXML(title)
        self.subtitle=self._sanitizeStringForXML(subtitle)
        self.valid=valid
        self.icon=icon
        self.autocomplete=autocomplete
        self.icontype=icontype

    def toXML(self):
        """
        Creates an XML representation of the AlfredItem
        :return:
        """
        item = "<item uid=\"{uid}\" arg=\"{arg}\" valid=\"{valid}\""
        if(self.autocomplete!=None):
            item += " autocomplete=\"{autocomplete}\""
        item += ">"
        item += "<title><![CDATA[{title}]]></title>"
        item += "<subtitle><![CDATA[{subtitle}]]></subtitle>"
        if (self.icon != None):
            if(self.icontype != None):
                item += "<icon type=\"{icontype}\">{icon}</icon>"
            else:
                item += "<icon>{icon}</icon>"
        item += "</item>"
        return item.format(uid=self.uid,arg=self.arg,valid="yes" if self.valid else "no",icontype=self.icontype,
                           title=self.title,subtitle=self.subtitle,icon=self.icon,autocomplete=self.autocomplete)

    def _sanitizeStringForXML(self,s):
        return s.encode("utf8").replace("\n"," ")
        #return cgi.escape(s.replace("\n"," "))

