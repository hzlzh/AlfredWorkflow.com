
__all__ = ['search_tasks', 'find_task_by_url', 'find_task_by_url_or_path', 'find_tasks_to_download', 'find_torrent_tasks_to_download', 'find_normal_tasks_to_download', 'expand_bt_sub_tasks', 'is_url', 'is_local_bt']

import re
import os
import urllib2
import fileinput

from lixian_encoding import default_encoding
import lixian_hash_bt
import lixian_hash_ed2k

import lixian_tasks_extended

def to_utf_8(url):
	try:
		return url.decode(default_encoding).encode('utf-8')
	except:
		return url

def link_normalize(url):
	from lixian_url import url_unmask, normalize_unicode_link
	url = url_unmask(url)
	if url.startswith('magnet:'):
		return 'bt://'+lixian_hash_bt.magnet_to_infohash(url).encode('hex')
	elif url.startswith('ed2k://'):
		return lixian_hash_ed2k.parse_ed2k_id(url)
	elif url.startswith('bt://'):
		return url.lower()
	elif url.startswith('http://') or url.startswith('ftp://'):
		return normalize_unicode_link(url)
	return url

def link_equals(x1, x2):
	return link_normalize(x1) == link_normalize(x2)

def link_in(url, links):
	for link in links:
		if link_equals(url, link):
			return True

def is_url(url):
	return re.match(r'\w+://|magnet:', url)

def is_local_bt(url):
	return (not is_url(url)) and url.lower().endswith('.torrent') and os.path.exists(url)

def is_id(x):
	return re.match(r'^#?\d+(/[-.\w\[\],\s*]+)?$', x) or re.match(r'^#?\d+-\d+$', x)

def find_task_by_url(tasks, url):
	for t in tasks:
		if link_equals(t['original_url'], url):
			return t

def find_task_by_url_or_path(tasks, url):
	if is_url(url):
		return find_task_by_url(tasks, url)
	elif is_local_bt(url):
		return find_task_by_url(tasks, 'bt://' + lixian_hash_bt.info_hash(url))
	else:
		raise NotImplementedError()

def find_tasks_by_range(tasks, x):
	m = re.match(r'^#?(\d+)-(\d+)$', x)
	begin = int(m.group(1))
	end = int(m.group(2))
	return filter(lambda x: begin <= x['#'] <= end, tasks)

def find_task_by_id(tasks, id):
	for t in tasks:
		if str(t['id']) == id or str(t['#']) == id or '#'+str(t['#']) == id:
			return t

def find_tasks_by_id(tasks, id):
	if re.match(r'^#?\d+-\d+$', id):
		return find_tasks_by_range(tasks, id)

	task_id, sub_id = re.match(r'^(#?\d+)(?:/([-.\w\[\],\s*]+))?$', id).groups()
	task = find_task_by_id(tasks, task_id)

	if not task:
		return []

	if not sub_id:
		return [task]

	assert task['type'] == 'bt', 'task %s is not a bt task' % task['name'].encode(default_encoding)
	matched = []
	if re.match(r'\[.*\]', sub_id):
		for sub_id in re.split(r'\s*,\s*', sub_id[1:-1]):
			assert re.match(r'^\d+(-\d+)?|\.\w+$', sub_id), sub_id
			if sub_id.startswith('.'):
				t = dict(task)
				t['index'] = sub_id
				matched.append(t)
			elif '-' in sub_id:
				start, end = sub_id.split('-')
				for i in range(int(start), int(end)+1):
					t = dict(task)
					t['index'] = str(i)
					matched.append(t)
			else:
				assert re.match(r'^\d+$', sub_id), sub_id
				t = dict(task)
				t['index'] = sub_id
				matched.append(t)
	elif re.match(r'^\.\w+$', sub_id):
		t = dict(task)
		t['index'] = sub_id
		matched.append(t)
	elif sub_id == '*':
		t = dict(task)
		t['index'] = sub_id
		matched.append(t)
	else:
		assert re.match(r'^\d+$', sub_id), sub_id
		t = dict(task)
		t['index'] = sub_id
		matched.append(t)
	return matched

def search_in_tasks(tasks, keywords):
	found = []
	for x in keywords:
		# search url and local bt
		if is_url(x) or is_local_bt(x):
			task = find_task_by_url_or_path(tasks, x)
			if task:
				found.append(task)
			else:
				found.append(x) # keep the task order per arguments
			continue
		# search id
		if is_id(x):
			matched = find_tasks_by_id(tasks, x)
			if matched:
				found += matched
				continue
		# search date
		if re.match(r'^\d{4}\.\d{2}\.\d{2}$', x):
			raise NotImplementedError()
			matched = filter(lambda t: t['date'] == v, tasks)
			if matched:
				found += matched
				continue
		# search name
		if type(x) == str:
			x = x.decode(default_encoding)
		matched = filter(lambda t: t['name'].lower().find(x.lower()) != -1, tasks)
		if matched:
			found += matched
		else:
			# keyword not matched
			pass
	found = merge_bt_sub_tasks(found)
	return filter(lambda x: type(x) == dict, found), filter(lambda x: type(x) != dict, found), found

def search_tasks(client, args, status='all'):
	if status == 'all':
		tasks = client.read_all_tasks()
	elif status == 'completed':
		tasks = client.read_all_tasks()
	else:
		raise NotImplementedError()
	return search_in_tasks(tasks, list(args))[0]

def find_torrent_tasks_to_download(client, links):
	tasks = client.read_all_tasks()
	hashes = set(t['bt_hash'].lower() for t in tasks if t['type'] == 'bt')
	link_hashes = []
	for link in links:
		if re.match(r'^(?:bt://)?([a-fA-F0-9]{40})$', link):
			info_hash = link[-40:].lower()
			if info_hash not in hashes:
				print 'Adding bt task', link
				client.add_torrent_task_by_info_hash(info_hash)
			link_hashes.append(info_hash)
		elif re.match(r'http://', link):
			print 'Downloading torrent file from', link
			torrent = urllib2.urlopen(link, timeout=60).read()
			info_hash = lixian_hash_bt.info_hash_from_content(torrent)
			if info_hash not in hashes:
				print 'Adding bt task', link
				client.add_torrent_task_by_content(torrent, os.path.basename(link))
			link_hashes.append(info_hash)
		elif os.path.exists(link):
			with open(link, 'rb') as stream:
				torrent = stream.read()
			info_hash = lixian_hash_bt.info_hash_from_content(torrent)
			if info_hash not in hashes:
				print 'Adding bt task', link
				client.add_torrent_task_by_content(torrent, os.path.basename(link))
			link_hashes.append(info_hash)
		else:
			raise NotImplementedError('Unknown torrent '+link)
	all_tasks = client.read_all_tasks()
	tasks = []
	for h in link_hashes:
		for t in all_tasks:
			if t['bt_hash'].lower() == h.lower():
				tasks.append(t)
				break
		else:
			raise NotImplementedError('not task found')
	return tasks

def return_my_tasks(all_tasks, links):
	tasks = []
	for x in links:
		if type(x) == dict:
			tasks.append(x)
		else:
			task = find_task_by_url_or_path(all_tasks, x)
			if not task:
				raise NotImplementedError('task not found, wired: '+x)
			tasks.append(task)
	return tasks

def find_normal_tasks_to_download(client, links):
	links = lixian_tasks_extended.extend_links(links)
	all_tasks = client.read_all_tasks()
	found, missing, all = search_in_tasks(all_tasks, links)
	to_add = set(missing)
	if to_add:
		print 'Adding below tasks:'
		for link in missing:
			print link
		links_to_add = filter(is_url, to_add)
		if links_to_add:
			client.add_batch_tasks(map(to_utf_8, links_to_add))
		for link in to_add:
			if is_url(link):
				# add_batch_tasks doesn't work for bt task, add bt task one by one...
				if link.startswith('bt://') or link.startswith('magnet:'):
					client.add_task(link)
			elif is_local_bt(link):
				with open(link, 'rb') as stream:
					torrent = stream.read()
				client.add_torrent_task_by_content(torrent, os.path.basename(link))
			else:
				raise NotImplementedError('Unsupported: '+link)
		all_tasks = client.read_all_tasks()
	try:
		return return_my_tasks(all_tasks, all)
	except NotImplementedError:
		import time
		time.sleep(5)
		return return_my_tasks(client.read_all_tasks(), all)

def find_tasks_to_download(client, args):
	links = []
	links.extend(args)
	if args.input:
		links.extend(line.strip() for line in fileinput.input(args.input) if line.strip())
	if args.torrent:
		return find_torrent_tasks_to_download(client, links)
	else:
		return find_normal_tasks_to_download(client, links)

def merge_bt_sub_tasks(tasks):
	result_tasks = []
	task_mapping = {}
	for task in tasks:
		if type(task) == dict:
			id = task['id']
			if id in task_mapping:
				if 'index' in task and 'files' in task_mapping[id]:
					task_mapping[id]['files'].append(task['index'])
			else:
				if 'index' in task:
					t = dict(task)
					t['files'] = [t['index']]
					del t['index']
					result_tasks.append(t)
					task_mapping[id] = t
				else:
					result_tasks.append(task)
					task_mapping[id] = task
		else:
			if task in task_mapping:
				pass
			else:
				result_tasks.append(task)
				task_mapping[task] = task
	return result_tasks

def expand_bt_sub_tasks(client, task):
	files = client.list_bt(task)
	not_ready = []
	single_file = False
	if len(files) == 1 and files[0]['name'] == task['name']:
		single_file = True
	if 'files' in task:
		ordered_files = []
		indexed_files = dict((f['index'], f) for f in files)
		subs = []
		for index in task['files']:
			if index == '*':
				subs.extend([x['index'] for x in files])
			elif index.startswith('.'):
				subs.extend([x['index'] for x in files if x['name'].lower().endswith(index.lower())])
			else:
				subs.append(int(index))
		for index in subs:
			t = indexed_files[index]
			if t not in ordered_files:
				if t['status_text'] != 'completed':
					not_ready.append(t)
				else:
					ordered_files.append(t)
		files = ordered_files
	return files, not_ready, single_file

