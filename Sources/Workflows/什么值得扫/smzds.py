#coding=utf-8
__author__ = 'Henter'

import urllib2
import xml.etree.ElementTree as et

def load_feeds(file):
    items = []
    #root = et.ElementTree('feeds').getroot()
    tree = et.parse(file)
    for elem in tree.iter(tag='item'):
        item = {}
        item['title'] = elem.find('title').text
        item['link'] = elem.find('link').text
        item['description'] = elem.find('description').text
        items.append(item)

    return items


url = 'http://www.smzds.com/feed'
file = 'feeds'
content = urllib2.urlopen(url).read()
handle = open(file, 'w')
handle.write(content)
handle.close()

items = load_feeds(file)

icon = 'icon.png'
print "<?xml version=\"1.0\"?>\n<items>"

if(items):
    for item in items:
        title = item['title']
        #subtitle = item['description'][0:100]
        subtitle = item['description']
        link = item['link']
        print "<item uid=\"smzds"+link+"\" arg=\""+ link +"\">"
        print "    <title>" + title.encode('utf-8') + "</title>"
        print "    <subtitle>" + subtitle.encode('utf-8')+ "</subtitle>"
        print "    <icon type=''>"+icon+"</icon>"
        print "</item>"
else:
        print "<item uid=\"smzds\" arg=\""+ url +"\">"
        print "    <title>暂无结果</title>"
        print "    <subtitle></subtitle>"
        print "    <icon type=''>"+icon+"</icon>"
        print "</item>"

print "</items>\n"
