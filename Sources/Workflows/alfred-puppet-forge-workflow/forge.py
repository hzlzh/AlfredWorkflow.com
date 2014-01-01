# Created by Spencer Owen
# https://github.com/spudstud
# twitter @spencer450

# Querries the puppet forge for select modules

import json
import urllib2
import sys
from xml.etree.ElementTree import Element, SubElement, Comment,  tostring

args = sys.argv
#print args[1]

if len(sys.argv) == 1:
	sys.exit("please specify a module to search for")


# Alfred runs this script every time a letter is passed in
# Causes slow downs because there are naturally more results for 'a' then 'abc'
# work around is to wait until atleast 3 characters are entered

if len(args[1]) <4:
	sys.exit("module name must have atlease 3 characters")



forgeurl="https://forge.puppetlabs.com/modules.json?q="+str(args[1])
jsonURL=urllib2.urlopen(forgeurl)
jsonObject=json.load(jsonURL)



# print jsonObject #For debugging

# Create a xml object that matches the documentaion 
# http://www.alfredforum.com/topic/5-generating-feedback-in-workflows/

items = Element('items')

for x in jsonObject:
	item = SubElement(items, 'item')
	item.set('uid', x['full_name'] )
	item.set('arg', "https://forge.puppetlabs.com/"+x['full_name']      ) # arg allows you to pass a string to other displays (notification center)
	item.set('valid', 'yes')

	title = SubElement(item, 'title')
	title.text = str( x['full_name'] )

	subtitle = SubElement(item, 'subtitle')
	subtitle.text = str( x['desc'] )

#icon = SubElement(item, 'icon')
#icon.text = "MtGox.png"
# print '....'
print tostring(items)