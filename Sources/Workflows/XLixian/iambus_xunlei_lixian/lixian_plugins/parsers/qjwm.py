
from lixian_plugins.api import page_parser

import urllib2
import re

def qjwm_link(url):
	assert re.match(r'http://.*\.qjwm\.com/down(load)?_\d+.html', url)
	url = url.replace('/down_', '/download_')
	html = urllib2.urlopen(url).read()
	m = re.search(r'var thunder_url = "([^"]+)";', html)
	if m:
		url = m.group(1)
		url = url.decode('gbk')
		return url


@page_parser('http://*.qjwm.com/*')
def extend_link(url):
	url = qjwm_link(url)
	return url and [url] or []

