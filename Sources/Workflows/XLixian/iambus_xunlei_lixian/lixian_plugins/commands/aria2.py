
from lixian_plugins.api import command

from lixian_config import *
from lixian_encoding import default_encoding
from lixian_cli_parser import command_line_parser
from lixian_cli_parser import with_parser
from lixian_cli_parser import command_line_value
from lixian_commands.util import parse_login, create_client

def export_aria2_conf(args):
	client = create_client(args)
	import lixian_query
	tasks = lixian_query.search_tasks(client, args)
	files = []
	for task in tasks:
		if task['type'] == 'bt':
			subs, skipped, single_file = lixian_query.expand_bt_sub_tasks(task)
			if not subs:
				continue
			if single_file:
				files.append((subs[0]['xunlei_url'], subs[0]['name'], None))
			else:
				for f in subs:
					import os.path
					files.append((f['xunlei_url'], f['name'], task['name']))
		else:
			files.append((task['xunlei_url'], task['name'], None))
	output = ''
	for url, name, dir in files:
		if type(url) == unicode:
			url = url.encode(default_encoding)
		output += url + '\n'
		output += '  out=' + name.encode(default_encoding) + '\n'
		if dir:
			output += '  dir=' + dir.encode(default_encoding) + '\n'
		output += '  header=Cookie: gdriveid=' + client.get_gdriveid() + '\n'
	return output

@command(usage='export task download urls as aria2 format')
@command_line_parser()
@with_parser(parse_login)
def export_aria2(args):
	'''
	usage: lx export-aria2 [id|name]...
	'''
	print export_aria2_conf(args)

def download_aria2_stdin(aria2_conf, j):
	aria2_opts = ['aria2c', '-i', '-', '-j', j]
	aria2_opts.extend(get_config('aria2-opts', '').split())
	from subprocess import Popen, PIPE
	sub = Popen(aria2_opts, stdin=PIPE, bufsize=1, shell=True)
	sub.communicate(aria2_conf)
	sub.stdin.close()
	exit_code = sub.wait()
	if exit_code != 0:
		raise Exception('aria2c exited abnormaly')

def download_aria2_temp(aria2_conf, j):
	import tempfile
	temp = tempfile.NamedTemporaryFile('w', delete=False)
	temp.file.write(aria2_conf)
	temp.file.close()
	try:
		aria2_opts = ['aria2c', '-i', temp.name, '-j', j]
		aria2_opts.extend(get_config('aria2-opts', '').split())
		import subprocess
		exit_code = subprocess.call(aria2_opts)
	finally:
		import os
		os.unlink(temp.name)
	if exit_code != 0:
		raise Exception('aria2c exited abnormaly')

@command(usage='concurrently download tasks in aria2')
@command_line_parser()
@with_parser(parse_login)
@command_line_value('max-concurrent-downloads', alias='j', default=get_config('aria2-j', '5'))
def download_aria2(args):
	'''
	usage: lx download-aria2 -j 5 [id|name]...
	'''
	aria2_conf = export_aria2_conf(args)
	import platform
	if platform.system() == 'Windows':
		download_aria2_temp(aria2_conf, args.max_concurrent_downloads)
	else:
		download_aria2_stdin(aria2_conf, args.max_concurrent_downloads)

