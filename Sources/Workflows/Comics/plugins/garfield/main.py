def enabled():
	return True

def title():
	return "Garfield"

def subtitle():
	return "View the latest Garfield strip"

def run():
	import feedparser
	import re
	import os
	d = feedparser.parse('http://www.hoodcomputing.com/garfield.php')
	strip = re.match('.*?src="(.*?)".*' , d['entries'][0]['summary_detail']['value'], re.IGNORECASE).groups(0)[0]
	os.system('curl -s ' + strip + ' --O strip.png')
	os.system('qlmanage -p strip.png')
