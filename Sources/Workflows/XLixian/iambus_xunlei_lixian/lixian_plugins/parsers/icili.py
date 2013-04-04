
from lixian_plugins.api import page_parser

import urllib2
import re

def icili_links(url):
	assert url.startswith('http://www.icili.com/emule/download/'), url
	html = urllib2.urlopen(url).read()
	table = re.search(r'<table id="emuleFile">.*?</table>', html, flags=re.S).group()
	links = re.findall(r'value="(ed2k://[^"]+)"', table)
	return links

@page_parser('http://www.icili.com/emule/download/')
def extend_link(url):
	links = icili_links(url)
	from lixian_hash_ed2k import parse_ed2k_file
	return [{'url':x, 'name':parse_ed2k_file(x)} for x in links]

