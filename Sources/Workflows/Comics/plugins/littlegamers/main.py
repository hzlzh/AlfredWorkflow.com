def enabled():
	return True

def title():
	return "Little Gamers"

def subtitle():
	return "The comic everyone knows, but no one reads"

def run():
	import feedparser
	import re
	import os
	d = feedparser.parse('http://feeds.feedburner.com/little-gamers/XrRa?format=xml')
	strip = re.match('.*?src="(.*?)".*' , d['entries'][0]['summary_detail']['value'], re.IGNORECASE).groups(0)[0]
	os.system('curl -s ' + strip + ' --O strip.png')
	os.system('qlmanage -p strip.png')
