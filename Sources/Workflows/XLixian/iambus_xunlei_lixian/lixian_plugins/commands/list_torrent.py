
from lixian_plugins.api import command

from lixian_cli_parser import parse_command_line
from lixian_config import get_config
from lixian_encoding import default_encoding

def b_encoding(b):
	if 'encoding' in b:
		return b['encoding']
	if 'codepage' in b:
		return 'cp' + str(b['codepage'])
	return 'utf-8'

def b_name(info, encoding='utf-8'):
	if 'name.utf-8' in info:
		return info['name.utf-8'].decode('utf-8')
	return info['name'].decode(encoding)

def b_path(f, encoding='utf-8'):
	if 'path.utf-8' in f:
		return [p.decode('utf-8') for p in f['path.utf-8']]
	return [p.decode(encoding) for p in f['path']]

@command(usage='list files in local .torrent')
def list_torrent(args):
	'''
	usage: lx list-torrent [--size] xxx.torrent...
	'''
	args = parse_command_line(args, [], ['size'], default={'size':get_config('size')})
	torrents = args
	if not torrents:
		from glob import glob
		torrents = glob('*.torrent')
	if not torrents:
		raise Exception('No .torrent file found')
	for p in torrents:
		with open(p, 'rb') as stream:
			from lixian_hash_bt import bdecode
			b = bdecode(stream.read())
			encoding = b_encoding(b)
			info = b['info']
			from lixian_util import format_size
			if args.size:
				size = sum(f['length'] for f in info['files']) if 'files' in info else info['length']
				print '*', b_name(info, encoding).encode(default_encoding), format_size(size)
			else:
				print '*', b_name(info, encoding).encode(default_encoding)
			if 'files' in info:
				for f in info['files']:
					if f['path'][0].startswith('_____padding_file_'):
						continue
					path = '/'.join(b_path(f, encoding)).encode(default_encoding)
					if args.size:
						print '%s (%s)' % (path, format_size(f['length']))
					else:
						print path
			else:
				path = b_name(info, encoding).encode(default_encoding)
				if args.size:
					from lixian_util import format_size
					print '%s (%s)' % (path, format_size(info['length']))
				else:
					print path

