def enabled():
	return True
	
def title():
	return "XKCD"

def subtitle():
	return "A webcomic of romance, sarcasm, math, and language."

def run():
	import feedparser
	import re
	import os
	d = feedparser.parse('http://xkcd.com/rss.xml')
	strip = re.match('.*?src="(.*?)".*' , d['entries'][0]['summary_detail']['value'], re.IGNORECASE).groups(0)[0]
	alt = re.match('.*?alt="(.*?)".*' , d['entries'][0]['summary_detail']['value'], re.IGNORECASE).groups(0)[0]
	title = d['entries'][0]['title']
	os.system('curl -s ' + strip + ' --O strip.png')
	comic = """
	<html>
	<head>
	<title>""" + title + """</title>
	</head>
	<body style="text-align:center;">
		<h1>""" +  title + """</h1>
		<img src='strip.png' />
		<p>""" + alt + """</p>
	</body>
	</html>
	"""
	with open("strip.html", "w") as text_file:
		text_file.write(comic)
	os.system('qlmanage -p strip.html')


