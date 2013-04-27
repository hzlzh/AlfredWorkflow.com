#!/usr/bin/env python
# -*- coding: utf-8 -*-

import urllib2
from xml.etree import ElementTree as ET


def get_items(uri):
    items = []
    tree = ET.ElementTree(file=urllib2.urlopen(uri))
    for it in tree.iter('item'):
        url = it.find('link').text
        items.append({
            'uid'           : url.split('/')[-1],
            'title'         : it.find('title').text, 
            'arg'           : url, 
            'description'   : it.find('description').text,
            'icon'          : 'icon.png',
        })

    xml = generate_xml(items)
    return xml


def generate_xml(items):
    xml_items = ET.Element('items')
    for item in items:
        xml_item = ET.SubElement(xml_items, 'item')
        for key in item.keys():
            if key in ('arg',):
                xml_item.set(key, item[key])
            else:
                child = ET.SubElement(xml_item, key)
                child.text = item[key]
    print ET.tostring(xml_items)
