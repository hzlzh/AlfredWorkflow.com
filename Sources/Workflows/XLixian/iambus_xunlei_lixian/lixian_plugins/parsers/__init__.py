
import re

page_parsers = {}

def register_parser(site, extend_link):
	page_parsers[site] = extend_link


def in_site(url, site):
	if url.startswith(site):
		return True
	if '*' in site:
		import fnmatch
		p = fnmatch.translate(site)
		return re.match(p, url)

def find_parser(link):
	for p in page_parsers:
		if in_site(link, p):
			return page_parsers[p]


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

def parse_pattern(link):
	m = re.search(r'[^:]//', link)
	if m:
		u = link[:m.start()+1]
		p = link[m.start()+3:]
		assert '//' not in p, link
		if p.endswith('/'):
			u += '/'
			p = p[:-1]
		return u, p

def try_to_extend_link(link):
	parser = find_parser(link)
	if parser:
		x = parse_pattern(link)
		if x:
			links = parser(x[0])
			import lixian_filter_expr
			return lixian_filter_expr.filter_expr(links, x[1])
		else:
			return parser(link)

def extend_link(link):
	return try_to_extend_link(link) or [link]

def extend_links_rich(links):
	return sum(map(extend_link, links), [])

def extend_links(links):
	return map(to_url, extend_links_rich(links))

def extend_links_name(links):
	return map(to_name, extend_links_rich(links))

