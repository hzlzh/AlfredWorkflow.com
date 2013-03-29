def enabled():
	return True

def title():
	return "Baby Blues"

def subtitle():
	return "The lighter side of parenting"

def run():
	import urllib2
	import re
	import os
	content = urllib2.urlopen('http://www.thecomicstrips.com/properties/template_strip_recent.php?id=147').read()
	strip = "http://cartoonistgroup.com" + re.match(r'.*?src="(/properties/babyblues/art_images/.*?)"' , content, re.IGNORECASE|re.S).groups(0)[0]
	os.system('curl -s ' + strip + ' --O strip.png')
	os.system('qlmanage -p strip.png')	
	