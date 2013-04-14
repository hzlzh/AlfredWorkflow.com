#!/usr/bin/python

import sys
from lxml import etree
from nsc import createXML

# create items element for Alfred
items = etree.Element("items")

# calculate binary number
binary = bin(int(sys.argv[1]))[2:]
# create associative array and create xml from it
b = {'uid':"binary", 'arg':binary, 'title':binary, 'subtitle':"Binary", 'icon':'icons/binary.png'}
item = createXML(b)
# append new item to items
items.append(item)


# calculate octal number
octal = oct(int(sys.argv[1]))[1:]
# create associative array and create xml from it
o = {'uid':"octal", 'arg':octal, 'title':octal, 'subtitle':"Octal", 'icon':'icons/octal.png'}
item = createXML(o)
# append new item to items
items.append(item)


# calculate hex number
hexadec = hex(int(sys.argv[1]))[2:]
# create associative array and create xml from it
h = {'uid':"hexadec", 'arg':hexadec, 'title':hexadec, 'subtitle':"Hexdecimal", 'icon':'icons/hex.png'}
item = createXML(h)
# append new item to items
items.append(item)

print (etree.tostring(items, pretty_print=True, xml_declaration=True))