
__all__ = ['filter_expr']

import re

def get_name(x):
	assert isinstance(x, (basestring, dict))
	if type(x) == dict:
		return x['name']
	else:
		return x

def filter_expr1(links, p):
	if not links:
		return links
	if re.match(r'^\[[^][]+\]$', p):
		matched = []
		for p in re.split(r'\s*,\s*', p[1:-1]):
			assert re.match(r'^\d+(-\d+)?|\.\w+$', p), p
			if re.match(r'^\d+$', p):
				i = int(p)
				matched.append((i, links[i]))
			elif '-' in p:
				start, end = p.split('-')
				if not start:
					start = 0
				if not end:
					end = len(links) - 1
				start = int(start)
				end = int(end)
				assert 0 <= start < len(links)
				assert 0 <= end < len(links)
				if start <= end:
					matched += list(enumerate(links))[start:end+1]
				else:
					matched += reversed(list(enumerate(links))[end:start+1])
			elif p.startswith('.'):
				matched += filter(lambda (i, x): get_name(x).lower().endswith(p.lower()), enumerate(links))
			else:
				raise NotImplementedError(p)
		indexes = []
		for i, _ in matched:
			if i not in indexes:
				indexes.append(i)
		return [links[x] for x in indexes]
	elif re.match(r'^\d+$', p):
		n = int(p)
		if 0 <= n < len(links):
			return [links[int(p)]]
		else:
			return filter(lambda x: re.search(p, get_name(x), re.I), links)
	elif p == '*':
		return links
	elif re.match(r'\.\w+$', p):
		return filter(lambda x: get_name(x).lower().endswith(p.lower()), links)
	else:
		import lixian_plugins.filters
		filter_results = lixian_plugins.filters.filter_things(links, p)
		if filter_results is None:
			return filter(lambda x: re.search(p, get_name(x), re.I), links)
		else:
			return filter_results

def filter_expr(links, expr):
	for p in expr.split('/'):
		links = filter_expr1(links, p)
	return links


