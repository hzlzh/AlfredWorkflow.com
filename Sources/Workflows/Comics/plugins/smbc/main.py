def enabled():
	return True

def title():
	return "S M B C"

def subtitle():
	return "Saturday Morning Breakfast Cereal"

def run():
	import urllib2
	import re
	import os
	content = urllib2.urlopen('http://www.smbc-comics.com/').read()
	strip = re.match(r'.*?src="(http://www.smbc-comics.com/comics/.*?)"' , content, re.IGNORECASE|re.S).groups(0)[0]
	os.system('curl -s ' + strip + ' --O strip.png')
	os.system('qlmanage -p strip.png')	
	