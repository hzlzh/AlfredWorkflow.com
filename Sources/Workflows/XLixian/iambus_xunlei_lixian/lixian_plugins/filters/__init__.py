
import re

name_filters = {}
task_filters = {}

def find_matcher(keyword, filters):
	for p in filters:
		if re.search(p, keyword):
			return filters[p]

def has_task_filter(keyword):
	return bool(find_matcher(keyword, task_filters))

def filter_tasks_with_matcher(tasks, keyword, (mode, m)):
	if mode == 'single':
		return filter(lambda x: m(keyword, x), tasks)
	elif mode == 'batch':
		return m(keyword, tasks)
	else:
		raise NotImplementedError(mode)

def filter_tasks(tasks, keyword):
	m = find_matcher(keyword, task_filters)
	if m:
		return filter_tasks_with_matcher(tasks, keyword, m)

def filter_things(things, keyword):
	if not things:
		# XXX: neither None or things should be OK
		return things
	assert len(set(map(type, things))) == 1
	filters = task_filters if type(things[0]) == dict else name_filters
	m = find_matcher(keyword, filters)
	if m:
		return filter_tasks_with_matcher(things, keyword, m)

def define_task_filter(pattern, matcher, batch=False):
	task_filters[pattern] = ('batch' if batch else 'single', matcher)

def define_name_filter(pattern, matcher):
	name_filters[pattern] = ('single', matcher)
	task_filters[pattern] = ('single', lambda k, x: matcher(k, x['name']))

def task_filter(pattern=None, protocol=None, batch=False):
	assert bool(pattern) ^ bool(protocol)
	def define_filter(matcher):
		if pattern:
			define_task_filter(pattern, matcher, batch)
		else:
			assert re.match(r'^[\w-]+$', protocol), protocol
			define_task_filter(r'^%s:' % protocol, lambda k, x: matcher(re.sub(r'^[\w-]+:', '', k), x), batch)
		return matcher
	return define_filter

def name_filter(pattern=None, protocol=None):
	# FIXME: duplicate code
	assert bool(pattern) ^ bool(protocol)
	def define_filter(matcher):
		if pattern:
			define_name_filter(pattern, matcher)
		else:
			assert re.match(r'^\w+$', protocol), protocol
			define_name_filter(r'^%s:' % protocol, lambda k, x: matcher(re.sub(r'^\w+:', '', k), x))
		return matcher
	return define_filter

