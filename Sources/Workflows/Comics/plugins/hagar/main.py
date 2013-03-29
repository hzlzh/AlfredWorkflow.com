def enabled():
	return True

def title():
	return u'Hagar'

def subtitle():
	return u'Hagar the Horrible'

def run():
	import urllib2
	import re
	import os
	content = urllib2.urlopen('http://www.thecomicstrips.com/properties/template_strip_recent.php?id=142').read()
	strip = "http://cartoonistgroup.com" + re.match(r'.*?src="(/properties/hagar/art_images/.*?)"' , content, re.IGNORECASE|re.S).groups(0)[0]
	os.system('curl -s ' + strip + ' --O strip.png')
	os.system('qlmanage -p strip.png')	
	