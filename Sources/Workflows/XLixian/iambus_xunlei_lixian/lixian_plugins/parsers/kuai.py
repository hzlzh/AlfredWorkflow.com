
from lixian_plugins.api import page_parser

import urllib
import re

def generate_lixian_url(info):
	print info['url']
	info = dict(info)
	info['namehex'] = '0102'
	info['fid'] = re.search(r'fid=([^&]+)', info['url']).group(1)
	info['tid'] = re.search(r'tid=([^&]+)', info['url']).group(1)
	info['internalid'] = '111'
	info['taskid'] = 'xxx'
	return 'http://gdl.lixian.vip.xunlei.com/download?fid=%(fid)s&mid=666&threshold=150&tid=%(tid)s&srcid=4&verno=1&g=%(gcid)s&scn=t16&i=%(gcid)s&t=1&ui=%(internalid)s&ti=%(taskid)s&s=%(size)s&m=0&n=%(namehex)s' % info

def parse_link(html):
	attrs = dict(re.findall(r'(\w+)="([^"]+)"', html))
	if 'file_url' not in attrs:
		return
	keys = {'url': 'file_url', 'name':'file_name', 'size':'file_size', 'gcid':'gcid', 'cid':'cid', 'gcid_resid':'gcid_resid'}
	info = {}
	for k in keys:
		info[k] = attrs[keys[k]]
	#info['name'] = urllib.unquote(info['name'])
	return info

@page_parser('http://kuai.xunlei.com/d/')
def kuai_links(url):
	assert url.startswith('http://kuai.xunlei.com/d/'), url
	html = urllib.urlopen(url).read().decode('utf-8')
	#return re.findall(r'file_url="([^"]+)"', html)
	#return map(parse_link, re.findall(r'<span class="f_w".*?</li>', html, flags=re.S))
	return filter(bool, map(parse_link, re.findall(r'<span class="c_1">.*?</span>', html, flags=re.S)))

extend_link = kuai_links

def main(args):
	from lixian_cli_parser import parse_command_line
	args = parse_command_line(args, [], ['name'])
	for x in args:
		for v in kuai_links(x):
			if args.name:
				print v['name']
			else:
				print v['url']


if __name__ == '__main__':
	import sys
	main(sys.argv[1:])

