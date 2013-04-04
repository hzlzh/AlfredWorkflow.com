# unread-instapaper.py v1.2
# View Unread Instapaper Articles in Alfred 2
# A Python Script by Kai Wells (2013)
# Probably not the most efficient way to do this, but it works!

from xml.etree import ElementTree as ET
import urllib, urllib2
import json
import re

def list(USERNAME, PASSWORD, QUERY = ""):
	# GET JSON DATA
	if re.search(re.compile('archive.*', re.IGNORECASE), QUERY):
		url = 'https://www.instapaper.com/api/1/bookmarks/list?folder_id=archive'
		q = ''
		for i in range(1, len(QUERY.split(" "))):
			q = q + QUERY.split(" ")[i] + " "
		QUERY = q.rstrip()
	elif re.search(re.compile(('starred.*'), re.IGNORECASE), QUERY) or re.search(re.compile(('liked.*'), re.IGNORECASE), QUERY):
		url = 'https://www.instapaper.com/api/1/bookmarks/list?folder_id=starred'
		q = ''
		for i in range(1, len(QUERY.split(" "))):
			q = q + QUERY.split(" ")[i] + " "
		QUERY = q.rstrip()
	else:
		url = 'https://www.instapaper.com/api/1/bookmarks/list'
	data = urllib.urlencode([('username', USERNAME), ('password', PASSWORD)])
	response = urllib2.urlopen(url, data)
	response_items = response.read()
	items = json.loads(response_items)
	# DELETE METADATA
	del items[0]
	del items[0]
	# PARSE ITEMS
	xml = []
	for item in items:
		if re.search(re.compile(QUERY, re.IGNORECASE), item[u'title']) or re.search(re.compile(QUERY, re.IGNORECASE), item[u'description']):
			xml.append ({
				'title': item[u'title'],
				'subtitle': item[u'description'],
				'arg': item[u'url'],
				'uid': item[u'hash'],
				'icon': 'icon.png'
			})
	# PLANT XML TREE
	xml_items = ET.Element('items')
	for item in xml:
		xml_item = ET.SubElement(xml_items, 'item')
		for key in item.keys():
			if key is 'uid' or key is 'arg':
				xml_item.set(key, item[key])
			else:
				child = ET.SubElement(xml_item, key)
				child.text = item[key]
	return ET.tostring(xml_items)