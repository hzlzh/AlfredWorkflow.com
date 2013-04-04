
from lixian_query import ExactQuery
from lixian_query import SearchQuery
from lixian_query import query
from lixian_query import bt_query

import lixian_hash_bt
import lixian_url
import lixian_encoding

import re

##################################################
# queries
##################################################

class SingleTaskQuery(ExactQuery):
	def __init__(self, base, t):
		super(SingleTaskQuery, self).__init__(base)
		self.id = t['id']

	def query_once(self):
		return [self.base.get_task_by_id(self.id)]

	def query_search(self):
		t = self.base.find_task_by_id(self.id)
		return [t] if t else []


@query(priority=1)
@bt_query(priority=1)
def single_id_processor(base, x):
	if not re.match(r'^\d+/?$', x):
		return
	n = x.rstrip('/')
	t = base.find_task_by_id(n)
	if t:
		return SingleTaskQuery(base, t)

##################################################

class MultipleTasksQuery(ExactQuery):
	def __init__(self, base, tasks):
		super(MultipleTasksQuery, self).__init__(base)
		self.tasks = tasks

	def query_once(self):
		return map(self.base.get_task_by_id, (t['id'] for t in self.tasks))

	def query_search(self):
		return filter(bool, map(self.base.find_task_by_id, (t['id'] for t in self.tasks)))

@query(priority=1)
@bt_query(priority=1)
def range_id_processor(base, x):
	m = re.match(r'^(\d+)-(\d+)$', x)
	if not m:
		return
	begin = int(m.group(1))
	end = int(m.group(2))
	tasks = base.get_tasks()
	if begin <= end:
		found = filter(lambda x: begin <= x['#'] <= end, tasks)
	else:
		found = reversed(filter(lambda x: end <= x['#'] <= begin, tasks))
	if found:
		return MultipleTasksQuery(base, found)

##################################################

class SubTaskQuery(ExactQuery):
	def __init__(self, base, t, subs):
		super(SubTaskQuery, self).__init__(base)
		self.task = t
		self.subs = subs

	def query_once(self):
		task = dict(self.base.get_task_by_id(self.task['id']))
		files = self.base.get_files(task)
		task['files'] = self.subs
		return [task]

	def query_search(self):
		task = self.base.find_task_by_id(self.task['id'])
		if not task:
			return []
		task = dict(task)
		files = self.base.get_files(task)
		task['files'] = self.subs
		return [task]

@query(priority=2)
@bt_query(priority=2)
def sub_id_processor(base, x):
	x = lixian_encoding.from_native(x)

	m = re.match(r'^(\d+)/(.+)$', x)
	if not m:
		return
	task_id, sub_id = m.groups()
	task = base.find_task_by_id(task_id)
	if not task:
		return

	assert task['type'] == 'bt', 'task %s is not a bt task' % lixian_encoding.to_native(task['name'])
	files = base.get_files(task)
	import lixian_filter_expr
	files = lixian_filter_expr.filter_expr(files, sub_id)
	subs = [x for x in files]
	return SubTaskQuery(base, task, subs)

##################################################

class BtHashQuery(ExactQuery):
	def __init__(self, base, x):
		super(BtHashQuery, self).__init__(base)
		self.hash = re.match(r'^(?:bt://)?([0-9a-f]{40})$', x, flags=re.I).group(1).lower()
		self.task = self.base.find_task_by_hash(self.hash)

	def prepare(self):
		if not self.task:
			self.base.add_bt_task_by_hash(self.hash)

	def query_once(self):
		t = self.base.find_task_by_hash(self.hash)
		assert t, 'Task not found: bt://' + self.hash
		return [t]

	def query_search(self):
		t = self.base.find_task_by_hash(self.hash)
		return [t] if t else []

@query(priority=1)
@bt_query(priority=1)
def bt_hash_processor(base, x):
	if re.match(r'^(bt://)?[0-9a-f]{40}$', x, flags=re.I):
		return BtHashQuery(base, x)

##################################################

class LocalBtQuery(ExactQuery):
	def __init__(self, base, x):
		super(LocalBtQuery, self).__init__(base)
		self.path = x
		self.hash = lixian_hash_bt.info_hash(self.path)
		self.task = self.base.find_task_by_hash(self.hash)
		with open(self.path, 'rb') as stream:
			self.torrent = stream.read()

	def prepare(self):
		if not self.task:
			self.base.add_bt_task_by_content(self.torrent, self.path)

	def query_once(self):
		t = self.base.find_task_by_hash(self.hash)
		assert t, 'Task not found: bt://' + self.hash
		return [t]

	def query_search(self):
		t = self.base.find_task_by_hash(self.hash)
		return [t] if t else []

@query(priority=1)
@bt_query(priority=1)
def local_bt_processor(base, x):
	import os.path
	if x.lower().endswith('.torrent') and os.path.exists(x):
		return LocalBtQuery(base, x)

##################################################

class MagnetQuery(ExactQuery):
	def __init__(self, base, x):
		super(MagnetQuery, self).__init__(base)
		self.url = x
		self.hash = lixian_hash_bt.magnet_to_infohash(x).encode('hex').lower()
		self.task = self.base.find_task_by_hash(self.hash)

	def prepare(self):
		if not self.task:
			self.base.add_magnet_task(self.url)

	def query_once(self):
		t = self.base.find_task_by_hash(self.hash)
		assert t, 'Task not found: bt://' + self.hash
		return [t]

	def query_search(self):
		t = self.base.find_task_by_hash(self.hash)
		return [t] if t else []

@query(priority=4)
@bt_query(priority=4)
def magnet_processor(base, url):
	if re.match(r'magnet:', url):
		return MagnetQuery(base, url)

##################################################

class BatchUrlsQuery(ExactQuery):
	def __init__(self, base, urls):
		super(BatchUrlsQuery, self).__init__(base)
		self.urls = urls

	def prepare(self):
		for url in self.urls:
			if not self.base.find_task_by_url(url):
				self.base.add_url_task(url)

	def query_once(self):
		return map(self.base.get_task_by_url, self.urls)

	def query_search(self):
		return filter(bool, map(self.base.find_task_by_url, self.urls))

@query(priority=6)
@bt_query(priority=6)
def url_extend_processor(base, url):
	import lixian_plugins.parsers
	extended = lixian_plugins.parsers.try_to_extend_link(url)
	if extended:
		extended = map(lixian_plugins.parsers.to_url, extended)
		return BatchUrlsQuery(base, extended)

##################################################

class UrlQuery(ExactQuery):
	def __init__(self, base, x):
		super(UrlQuery, self).__init__(base)
		self.url = lixian_url.url_unmask(x)
		self.task = self.base.find_task_by_url(self.url)

	def prepare(self):
		if not self.task:
			self.base.add_url_task(self.url)

	def query_once(self):
		t = self.base.find_task_by_url(self.url)
		assert t, 'Task not found: bt://' + self.url
		return [t]

	def query_search(self):
		t = self.base.find_task_by_url(self.url)
		return [t] if t else []

@query(priority=7)
def url_processor(base, url):
	if re.match(r'\w+://', url):
		return UrlQuery(base, url)

##################################################

class BtUrlQuery(ExactQuery):
	def __init__(self, base, url, torrent):
		super(BtUrlQuery, self).__init__(base)
		self.url = url
		self.torrent = torrent
		self.hash = lixian_hash_bt.info_hash_from_content(self.torrent)
		self.task = self.base.find_task_by_hash(self.hash)

	def prepare(self):
		if not self.task:
			self.base.add_bt_task_by_content(self.torrent, self.url)

	def query_once(self):
		t = self.base.find_task_by_hash(self.hash)
		assert t, 'Task not found: bt://' + self.hash
		return [t]

	def query_search(self):
		t = self.base.find_task_by_hash(self.hash)
		return [t] if t else []

@bt_query(priority=7)
def bt_url_processor(base, url):
	if not re.match(r'http://', url):
		return
	print 'Downloading torrent file from', url
	import urllib2
	torrent = urllib2.urlopen(url, timeout=60).read()
	return BtUrlQuery(base, url, torrent)

##################################################

class FilterQuery(SearchQuery):
	def __init__(self, base, x):
		super(FilterQuery, self).__init__(base)
		self.keyword = x

	def query_search(self):
		import lixian_plugins.filters
		tasks = lixian_plugins.filters.filter_tasks(self.base.get_tasks(), self.keyword)
		assert tasks is not None
		return tasks

@query(priority=8)
@bt_query(priority=8)
def filter_processor(base, x):
	import lixian_plugins.filters
	if lixian_plugins.filters.has_task_filter(x):
		return FilterQuery(base, x)

##################################################

class DefaultQuery(SearchQuery):
	def __init__(self, base, x):
		super(DefaultQuery, self).__init__(base)
		self.text = lixian_encoding.from_native(x)

	def query_search(self):
		return filter(lambda t: t['name'].lower().find(self.text.lower()) != -1, self.base.get_tasks())

@query(priority=9)
@bt_query(priority=9)
def default_processor(base, x):
	return DefaultQuery(base, x)

