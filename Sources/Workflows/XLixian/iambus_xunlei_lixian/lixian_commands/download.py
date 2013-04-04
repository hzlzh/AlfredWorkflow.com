
from lixian_commands.util import *
from lixian_cli_parser import *
from lixian_config import *
from lixian_encoding import default_encoding
from lixian_colors import colors
import lixian_help
import lixian_query
import lixian_hash
import lixian_hash_bt
import lixian_hash_ed2k
import os
import os.path
import re

def escape_filename(name):
	amp = re.compile(r'&(amp;)+', flags=re.I)
	name = re.sub(amp, '&', name)
	name = re.sub(r'[\\/:*?"<>|]', '-', name)
	return name


def verify_basic_hash(path, task):
	if os.path.getsize(path) != task['size']:
		print 'hash error: incorrect file size'
		return False
	return lixian_hash.verify_dcid(path, task['dcid'])

def verify_hash(path, task):
	if verify_basic_hash(path, task):
		if task['type'] == 'ed2k':
			return lixian_hash_ed2k.verify_ed2k_link(path, task['original_url'])
		else:
			return True

def verify_mini_hash(path, task):
	return os.path.exists(path) and os.path.getsize(path) == task['size'] and lixian_hash.verify_dcid(path, task['dcid'])

def verify_mini_bt_hash(dirname, files):
	for f in files:
		name = f['name'].encode(default_encoding)
		path = os.path.join(dirname, *name.split('\\'))
		if not verify_mini_hash(path, f):
			return False
	return True

def download_single_task(client, download, task, options):
	output = options.get('output')
	output = output and os.path.expanduser(output)
	output_dir = options.get('output_dir')
	output_dir = output_dir and os.path.expanduser(output_dir)
	delete = options.get('delete')
	resuming = options.get('resuming')
	overwrite = options.get('overwrite')
	mini_hash = options.get('mini_hash')
	no_hash = options.get('no_hash')
	no_bt_dir = options.get('no_bt_dir')
	save_torrent_file = options.get('save_torrent_file')

	assert client.get_gdriveid()
	if task['status_text'] != 'completed':
		if 'files' not in task:
			with colors(options.get('colors')).yellow():
				print 'skip task %s as the status is %s' % (task['name'].encode(default_encoding), task['status_text'])
			return
	def download1(client, url, path, size):
		if not os.path.exists(path):
			download(client, url, path)
		elif not resuming:
			if overwrite:
				download(client, url, path)
			else:
				raise Exception('%s already exists. Please try --continue or --overwrite' % path)
		else:
			assert os.path.getsize(path) <= size, 'existing file bigger than expected, unsafe to continue nor overwrite'
			if os.path.getsize(path) < size:
				download(client, url, path, resuming)
			elif os.path.getsize(path) == size:
				pass
			else:
				raise NotImplementedError()
	def download2(client, url, path, task):
		size = task['size']
		if mini_hash and resuming and verify_mini_hash(path, task):
			return
		download1(client, url, path, size)
		verify = verify_basic_hash if no_hash else verify_hash
		if not verify(path, task):
			with colors(options.get('colors')).yellow():
				print 'hash error, redownloading...'
			os.remove(path)
			download1(client, url, path, size)
			if not verify(path, task):
				raise Exception('hash check failed')
	download_url = str(task['xunlei_url'])
	if output:
		output_path = output
		output_dir = os.path.dirname(output)
		output_name = os.path.basename(output)
	else:
		output_name = escape_filename(task['name']).encode(default_encoding)
		output_dir = output_dir or '.'
		output_path = os.path.join(output_dir, output_name)
	referer = str(client.get_referer())
	gdriveid = str(client.get_gdriveid())

	if task['type'] == 'bt':
		files, skipped, single_file = lixian_query.expand_bt_sub_tasks(task)
		if single_file:
			dirname = output_dir
		else:
			if no_bt_dir:
				output_path = os.path.dirname(output_path)
			dirname = output_path
		assert dirname # dirname must be non-empty, otherwise dirname + os.path.sep + ... might be dangerous
		if dirname and not os.path.exists(dirname):
			os.makedirs(dirname)
		for t in skipped:
			with colors(options.get('colors')).yellow():
				print 'skip task %s/%s (%s) as the status is %s' % (str(t['id']), t['index'], t['name'].encode(default_encoding), t['status_text'])
		if mini_hash and resuming and verify_mini_bt_hash(dirname, files):
			print task['name'].encode(default_encoding), 'is already done'
			if delete and 'files' not in task:
				client.delete_task(task)
			return
		if not single_file:
			with colors(options.get('colors')).green():
				print output_name + '/'
		for f in files:
			name = f['name']
			if f['status_text'] != 'completed':
				print 'Skipped %s file %s ...' % (f['status_text'], name.encode(default_encoding))
				continue
			if not single_file:
				print name.encode(default_encoding), '...'
			else:
				with colors(options.get('colors')).green():
					print name.encode(default_encoding), '...'
			# XXX: if file name is escaped, hashing bt won't get correct file
			splitted_path = map(escape_filename, name.split('\\'))
			name = os.path.join(*splitted_path).encode(default_encoding)
			path = dirname + os.path.sep + name # fix issue #82
			if splitted_path[:-1]:
				subdir = os.path.join(*splitted_path[:-1]).encode(default_encoding)
				subdir = dirname + os.path.sep + subdir # fix issue #82
				if not os.path.exists(subdir):
					os.makedirs(subdir)
			download_url = str(f['xunlei_url'])
			download2(client, download_url, path, f)
		if save_torrent_file:
			info_hash = str(task['bt_hash'])
			if single_file:
				torrent = os.path.join(dirname, escape_filename(task['name']).encode(default_encoding) + '.torrent')
			else:
				torrent = os.path.join(dirname, info_hash + '.torrent')
			if os.path.exists(torrent):
				pass
			else:
				content = client.get_torrent_file_by_info_hash(info_hash)
				with open(torrent, 'wb') as ouput_stream:
					ouput_stream.write(content)
		if not no_hash:
			torrent_file = client.get_torrent_file(task)
			print 'Hashing bt ...'
			from lixian_progress import SimpleProgressBar
			bar = SimpleProgressBar()
			file_set = [f['name'].encode('utf-8').split('\\') for f in files] if 'files' in task else None
			verified = lixian_hash_bt.verify_bt(output_path, lixian_hash_bt.bdecode(torrent_file)['info'], file_set=file_set, progress_callback=bar.update)
			bar.done()
			if not verified:
				# note that we don't delete bt download folder if hash failed
				raise Exception('bt hash check failed')
	else:
		if output_dir and not os.path.exists(output_dir):
			os.makedirs(output_dir)

		with colors(options.get('colors')).green():
			print output_name, '...'
		download2(client, download_url, output_path, task)

	if delete and 'files' not in task:
		client.delete_task(task)

def download_multiple_tasks(client, download, tasks, options):
	for task in tasks:
		download_single_task(client, download, task, options)
	skipped = filter(lambda t: t['status_text'] != 'completed', tasks)
	if skipped:
		with colors(options.get('colors')).yellow():
			print "Below tasks were skipped as they were not ready:"
		for task in skipped:
			print task['id'], task['status_text'], task['name'].encode(default_encoding)

@command_line_parser(help=lixian_help.download)
@with_parser(parse_login)
@with_parser(parse_colors)
@with_parser(parse_logging)
@command_line_value('tool', default=get_config('tool', 'wget'))
@command_line_value('input', alias='i')
@command_line_value('output', alias='o')
@command_line_value('output-dir', default=get_config('output-dir'))
@command_line_option('torrent', alias='bt')
@command_line_option('all')
@command_line_value('category')
@command_line_option('delete', default=get_config('delete'))
@command_line_option('continue', alias='c', default=get_config('continue'))
@command_line_option('overwrite')
@command_line_option('mini-hash', default=get_config('mini-hash'))
@command_line_option('hash', default=get_config('hash', True))
@command_line_option('bt-dir', default=True)
@command_line_option('save-torrent-file')
@command_line_option('watch')
@command_line_option('watch-present')
@command_line_value('watch-interval', default=get_config('watch-interval', '3m'))
def download_task(args):
	import lixian_download_tools
	download = lixian_download_tools.get_tool(args.tool)
	download_args = {'output': args.output,
	                 'output_dir': args.output_dir,
	                 'delete': args.delete,
	                 'resuming': args._args['continue'],
	                 'overwrite': args.overwrite,
	                 'mini_hash': args.mini_hash,
	                 'no_hash': not args.hash,
	                 'no_bt_dir': not args.bt_dir,
	                 'save_torrent_file': args.save_torrent_file,
	                 'colors': args.colors}
	client = create_client(args)
	assert len(args) or args.input or args.all or args.category, 'Not enough arguments'
	query = lixian_query.build_query(client, args)
	query.query_once()

	def sleep(n):
		assert isinstance(n, (int, basestring)), repr(n)
		import time
		if isinstance(n, basestring):
			n, u = re.match(r'^(\d+)([smh])?$', n.lower()).groups()
			n = int(n) * {None: 1, 's': 1, 'm': 60, 'h': 3600}[u]
		time.sleep(n)

	if args.watch_present:
		assert not args.output, 'not supported with watch option yet'
		tasks = query.pull_completed()
		while True:
			if tasks:
				download_multiple_tasks(client, download, tasks, download_args)
			if not query.download_jobs:
				break
			if not tasks:
				sleep(args.watch_interval)
			query.refresh_status()
			tasks = query.pull_completed()

	elif args.watch:
		assert not args.output, 'not supported with watch option yet'
		tasks = query.pull_completed()
		while True:
			if tasks:
				download_multiple_tasks(client, download, tasks, download_args)
			if (not query.download_jobs) and (not query.queries):
				break
			if not tasks:
				sleep(args.watch_interval)
			query.refresh_status()
			query.query_search()
			tasks = query.pull_completed()

	else:
		tasks = query.peek_download_jobs()
		if args.output:
			assert len(tasks) == 1
			download_single_task(client, download, tasks[0], download_args)
		else:
			download_multiple_tasks(client, download, tasks, download_args)
