#!/usr/bin/python

""" Arguments
	sys.argv[0] = filename
	sys.argv[1] = number
	sys.argv[2] = source
	sys.argv[3] = destination
"""

import sys
from lxml import etree
from nsc  import createXML

"""
destSystem expects a decimal number and the base of new number system
"""
def destSystem(number, base):
	convertedNumber = ""

	while (number > 0):
		convertedNumber = str(number % base) + convertedNumber;
		number          = number / base

	return convertedNumber

# create items element for Alfred
items = etree.Element("items")

if (len(sys.argv) == 4):
	# calculate integer first
	decimal = int(sys.argv[1], int(sys.argv[2]))
	# create associative array and create xml from it
	d = {'uid':"decimal", 'arg':str(decimal), 'title':str(decimal),	'subtitle':"Decimal", 'icon':'icons/decimal.png'}
	item = createXML(d)
	# append new item to items
	items.append(item)

	# calculate new number
	conv = destSystem(decimal, int(sys.argv[3]))
	# create associative array and create xml from it
	c = {'uid':"conv", 'arg':conv, 'title':conv, 'subtitle':"Number to base " + sys.argv[3]}
	item = createXML(c)
	# append new item to items
	items.append(item)

else:
	error_string = "<items><item arg='error' uid='error' valid='no'><title>Make sure to pass 3 numbers</title><subtitle>for help type \"nsc help\"</subtitle></item></items>"
	items = etree.fromstring(error_string)

print (etree.tostring(items, pretty_print=True, xml_declaration=True))