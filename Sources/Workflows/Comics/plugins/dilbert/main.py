def enabled():
	return True

def title():
	return "Dilbert"

def subtitle():
	return "View Dilbert's daily strip"

def run():
	import feedparser
	import re
	import os
	d = feedparser.parse('http://feed.dilbert.com/dilbert/daily_strip?format=xml')
	strip = re.match(r'<img[^>]*\ssrc="(.*?)"' , d['entries'][0]['summary_detail']['value'], re.IGNORECASE).groups(0)[0]
	os.system('curl -s ' + strip + ' --O strip.png')
	os.system('qlmanage -p strip.png')	
