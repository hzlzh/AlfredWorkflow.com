
from lixian_plugins.api import command

from lixian_cli_parser import command_line_parser
from lixian_cli_parser import with_parser
from lixian_cli import parse_login
from lixian_commands.util import create_client

@command(name='get-torrent', usage='get .torrent by task id or info hash')
@command_line_parser()
@with_parser(parse_login)
def get_torrent(args):
	'''
	usage: lx get-torrent [info-hash|task-id]...
	'''
	client = create_client(args)
	for id in args:
		id = id.lower()
		import re
		if re.match(r'[a-fA-F0-9]{40}$', id):
			torrent = client.get_torrent_file_by_info_hash(id)
		elif re.match(r'\d+$', id):
			import lixian_query
			task = lixian_query.get_task_by_id(client, id)
			id = task['bt_hash']
			id = id.lower()
			torrent = client.get_torrent_file_by_info_hash(id)
		else:
			raise NotImplementedError()
		path = id + '.torrent'
		print path
		with open(path, 'wb') as output:
			output.write(torrent)

