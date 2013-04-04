
from lixian_plugins.api import task_filter

@task_filter(protocol='sort', batch=True)
def sort_by_name(keyword, tasks):
	'''
	Example:
	lx list sort:
	lx download 0/sort:/[0-1]
	'''
	return sorted(tasks, key=lambda x: x['name'])
