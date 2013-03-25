
__all__ = []

from lixian import XunleiClient
from lixian_config import *
from lixian_encoding import default_encoding
from lixian_cli_parser import parse_command_line
from lixian_cli_parser import expand_command_line

##################################################
# command decorator
##################################################

def command(name='', usage='', help=''):
	def as_command(f):
		assert usage, 'missing command usage: ' + f.func_name
		f.command_name = name or f.func_name.replace('_', '-')
		f.command_usage = usage
		f.command_help = help or f.func_doc
		import textwrap
		if f.command_help:
			f.command_help = textwrap.dedent(f.command_help)
		return f
	return as_command

##################################################

@command(usage='echo arguments')
def echo(args):
	'''
	lx echo ...
	'''
	print ' '.join(expand_command_line(args))

##################################################

@command(name='hash', usage='compute hashes')
def print_hash(args):
	'''
	lx hash --sha1 file...
	lx hash --md5 file...
	lx hash --md4 file...
	lx hash --dcid file...
	lx hash --ed2k file...
	lx hash --info-hash xxx.torrent...
	lx hash --verify-sha1 file hash
	lx hash --verify-md5 file hash
	lx hash --verify-md4 file hash
	lx hash --verify-dcid file hash
	lx hash --verify-ed2k file ed2k://...
	lx hash --verify-bt file xxx.torrent
	'''
	#assert len(args) == 1
	import lixian_hash
	#import lixian_hash_ed2k
	#print 'ed2k:', lixian_hash_ed2k.hash_file(args[0])
	#print 'dcid:', lixian_hash.dcid_hash_file(args[0])
	lixian_hash.main(expand_command_line(args))


##################################################

@command(name='diagnostics', usage='print helpful information for diagnostics')
def lx_diagnostics(args):
	'''
	usage: lx diagnostics
	'''
	print 'default_encoding ->', default_encoding
	import sys
	print 'sys.getdefaultencoding() ->', sys.getdefaultencoding()
	print 'sys.getfilesystemencoding() ->', sys.getfilesystemencoding()
	print r"print u'\u4e2d\u6587'.encode('utf-8') ->", u'\u4e2d\u6587'.encode('utf-8')
	print r"print u'\u4e2d\u6587'.encode('gbk') ->", u'\u4e2d\u6587'.encode('gbk')

##################################################

@command(usage='convert thunder:// (and more) to normal url')
def decode_url(args):
	'''
	usage: lx decode-url thunder://...
	'''
	from lixian_url import url_unmask
	for x in args:
		print url_unmask(x)

##################################################

@command(usage='parse links from kuai.xunlei.com')
def kuai(args):
	'''
	usage: lx kuai http://kuai.xunlei.com/d/xxx...
	
	Note that you can simply use:
	 lx add http://kuai.xunlei.com/d/xxx...
	or:
	 lx download http://kuai.xunlei.com/d/xxx...
	'''
	import lixian_kuai
	lixian_kuai.main(args)

##################################################

@command(usage='parse links')
def extend_links(args):
	'''
	usage: lx extend-links http://kuai.xunlei.com/d/... http://www.verycd.com/topics/...
	
	parse and print links from pages
	
	lx extend-links urls...
	lx extend-links --name urls...
	'''
	args = parse_command_line(args, [], ['name'])
	import lixian_tasks_extended
	for x in (lixian_tasks_extended.extend_links if not args.name else lixian_tasks_extended.extend_links_name)(args):
		print x

##################################################

@command(usage='list files in local .torrent')
def list_torrent(args):
	'''
	usage: lx list-torrent [--size] xxx.torrent...
	'''
	args = parse_command_line(args, [], ['size'])
	for p in args:
		with open(p, 'rb') as stream:
			from lixian_hash_bt import bdecode
			info = bdecode(stream.read())['info']
			print '*', info['name'].decode('utf-8').encode(default_encoding)
			if 'files' in info:
				for f in info['files']:
					if f['path'][0].startswith('_____padding_file_'):
						continue
					path = '/'.join(f['path']).decode('utf-8').encode(default_encoding)
					if args.size:
						from lixian_util import format_size
						print '%s (%s)' % (path, format_size(f['length']))
					else:
						print path
			else:
				path = info['name'].decode('utf-8').encode(default_encoding)
				if args.size:
					from lixian_util import format_size
					print '%s (%s)' % (path, format_size(info['length']))
				else:
					print path

##################################################

@command(usage='get .torrent by task id or info hash')
def get_torrent(args):
	'''
	usage: lx get-torrent [info-hash|task-id]...
	'''
	from lixian_cli import parse_login_command_line
	args = parse_login_command_line(args)
	client = XunleiClient(args.username, args.password, args.cookies)
	for id in args:
		id = id.lower()
		import re
		if re.match(r'[a-fA-F0-9]{40}$', id):
			torrent = client.get_torrent_file_by_info_hash(id)
		elif re.match(r'#?\d+$', id):
			tasks = client.read_all_tasks()
			from lixian_tasks import find_task_by_id
			task = find_task_by_id(tasks, id)
			assert task, id + ' not found'
			id = task['bt_hash']
			id = id.lower()
			torrent = client.get_torrent_file_by_info_hash(id)
		else:
			raise NotImplementedError()
		path = id + '.torrent'
		print path
		with open(path, 'wb') as output:
			output.write(torrent)

##################################################

def export_aria2_conf(args):
	client = XunleiClient(args.username, args.password, args.cookies)
	import lixian_tasks
	tasks = lixian_tasks.search_tasks(client, args, status=(args.completed and 'completed' or 'all'))
	files = []
	for task in tasks:
		if task['type'] == 'bt':
			subs, skipped, single_file = lixian_tasks.expand_bt_sub_tasks(client, task)
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
def export_aria2(args):
	'''
	usage: lx export-aria2 [id|name]...
	'''
	from lixian_cli import parse_login_command_line
	args = parse_login_command_line(args)
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
def download_aria2(args):
	'''
	usage: lx download-aria2 -j 5 [id|name]...
	'''
	from lixian_cli import parse_login_command_line
	args = parse_login_command_line(args, keys=['j'], alias={'max-concurrent-downloads':'j'})
	j = get_config('aria2-j', args.j) or '5'
	aria2_conf = export_aria2_conf(args)
	import platform
	if platform.system() == 'Windows':
		download_aria2_temp(aria2_conf, j)
	else:
		download_aria2_stdin(aria2_conf, j)

##################################################
# update helps
##################################################

extended_commands = [
		echo,
		print_hash,
		lx_diagnostics,
		decode_url,
		kuai,
		extend_links,
		list_torrent,
		get_torrent,
		export_aria2,
		download_aria2,
		]

commands = dict((x.command_name, x) for x in extended_commands)

def update_helps(commands):
	helps = dict((name, doc) for (name, usage, doc) in commands)

	if commands:
		import lixian_help
		lixian_help.extended_usage = '''\nExtended commands:
''' + lixian_help.join_commands([(x[0], x[1]) for x in commands])

	for name, usage, doc in commands:
		assert not hasattr(lixian_help, name)
		setattr(lixian_help, name, doc)

update_helps([(x.command_name, x.command_usage, x.command_help) for x in extended_commands])

