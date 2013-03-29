def enabled():
	return True

def title():
	return "Calvin and Hobbes"

def subtitle():
	return "View Calvin's adventures with good old Hobbes"

def run():
	import feedparser
	import re
	import os
	d = feedparser.parse('http://calvinhobbesdaily.tumblr.com/rss')
	strip = re.match(r'<img[^>]*\ssrc="(.*?)"' , d['entries'][0]['summary_detail']['value'], re.IGNORECASE).groups(0)[0]
	# tweak, must be done by tumblr I suppose
	strip = strip.replace("_500.gif", "_1280.gif")
	os.system('curl -s ' + strip + ' --O strip.png')
	os.system('qlmanage -p strip.png')
