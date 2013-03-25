
import re

sites = {
'http://kuai.xunlei.com/d/':'lixian_kuai',
'http://www.verycd.com/topics/':'lixian_verycd',
}

def to_name(x):
	if type(x) == dict:
		return x['name']
	else:
		return x

def to_url(x):
	if type(x) == dict:
		return x['url']
	else:
		return x

def filter_links1(links, p):
	if re.match(r'^\[[^][]+\]$', p):
		indexes = []
		for p in re.split(r'\s*,\s*', p[1:-1]):
			if re.match(r'^\d+$', p):
				i = int(p)
				if i not in indexes:
					indexes.append(i)
			elif '-' in p:
				start, end = p.split('-')
				if not start:
					start = 0
				if not end:
					end = len(links) - 1
				for i in range(int(start), int(end)+1):
					if i not in indexes:
						indexes.append(i)
			else:
				raise NotImplementedError(p)
		return [links[x] for x in indexes if 0 <= x < len(links)]
	else:
		return filter(lambda x: re.search(p, to_name(x), re.I), links)

def filter_links(links, patterns):
	for p in patterns:
		links = filter_links1(links, p)
	return links

def parse_pattern(link):
	m = re.search(r'[^:]//', link)
	if m:
		u = link[:m.start()+1]
		p = link[m.start()+3:]
		assert '//' not in p, link
		if p.endswith('/'):
			u += '/'
			p = p[:-1]
		return u, p.split('/')

def extend_link(link):
	for p in sites:
		if link.startswith(p):
			x = parse_pattern(link)
			if x:
				links = __import__(sites[p]).extend_link(x[0])
				return filter_links(links, x[1])
			else:
				return __import__(sites[p]).extend_link(link)
	return [link]

def extend_links_rich(links):
	return sum(map(extend_link, links), [])

def extend_links(links):
	return map(to_url, extend_links_rich(links))

def extend_links_name(links):
	return map(to_name, extend_links_rich(links))

