
from lixian_plugins.api import task_filter

import re

@task_filter(protocol='total-size', batch=True)
def fetch_by_total_size(keyword, tasks):
	'''
	Example:
	lx download total_size:1g
	lx download 0/total_size:1g
	lx list total_size:1g
	'''
	m = re.match(r'^(\d+(?:\.\d+)?)([GM])?$', keyword, flags=re.I)
	assert m, keyword
	n, u = m.groups()
	limit = float(n) * {None: 1, 'G': 1000**3, 'g': 1000**3, 'M': 1000**2, 'm': 1000**2}[u]
	total = 0
	results = []
	for t in tasks:
		total += t['size']
		if total <= limit:
			results.append(t)
		else:
			return results
	return results

