#!/usr/bin/python
""" -----------------------------------
	Script: 	Number System Converter
	Author: 	Hans-Helge Buerger
	Usage:		nsc <source> <number>
	Desc:		  Converts numbers from one into another number system
	Updated:	12.April 2013
	Version:	2.0dev 
----------------------------------- """

from lxml import etree

"""
createXML expects and associative array to generate XML out of it
It has to be done to display the converted numbers live in Alfred 2
"""
def createXML(data):
		item = etree.Element("item", uid=data['uid'], arg=data['arg'])

		title = etree.SubElement(item, "title")
		title.text = data['title']

		subtitle = etree.SubElement(item, "subtitle")
		subtitle.text = data['subtitle']

		icon = etree.SubElement(item, "icon")
		if 'icon' in data:
			icon.text = data['icon']
		else:
			icon.text = 'icon.png'

		return item