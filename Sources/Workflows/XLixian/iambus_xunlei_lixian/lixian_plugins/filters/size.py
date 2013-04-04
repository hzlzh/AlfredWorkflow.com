
from lixian_plugins.api import task_filter

import re

@task_filter(protocol='size')
def filter_by_size(keyword, task):
	'''
	Example:
	lx download size:10m-
	lx download size:1G+
	lx download 0/size:1g-
	'''
	m = re.match(r'^([<>])?(\d+(?:\.\d+)?)([GM])?([+-])?$', keyword, flags=re.I)
	assert m, keyword
	less_or_great, n, u, less_or_more = m.groups()
	assert bool(less_or_great) ^ bool(less_or_more), 'must bt <size, >size, size-, or size+'
	size = float(n) * {None: 1, 'G': 1000**3, 'g': 1000**3, 'M': 1000**2, 'm': 1000**2}[u]
	if less_or_great == '<' or less_or_more == '-':
		return task['size'] < size
	else:
		return task['size'] > size

