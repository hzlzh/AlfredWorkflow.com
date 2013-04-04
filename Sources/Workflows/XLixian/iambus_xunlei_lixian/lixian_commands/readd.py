
from lixian_commands.util import *
from lixian_cli_parser import *
from lixian_encoding import default_encoding
import lixian_help
import lixian_query

@command_line_parser(help=lixian_help.readd)
@with_parser(parse_login)
@with_parser(parse_logging)
@command_line_option('deleted')
@command_line_option('expired')
@command_line_option('all')
def readd_task(args):
	if args.deleted:
		status = 'deleted'
	elif args.expired:
		status = 'expired'
	else:
		raise NotImplementedError('Please use --expired or --deleted')
	client = create_client(args)
	if status == 'expired' and args.all:
		return client.readd_all_expired_tasks()
	to_readd = lixian_query.search_tasks(client, args)
	non_bt = []
	bt = []
	if not to_readd:
		return
	print "Below files are going to be re-added:"
	for x in to_readd:
		print x['name'].encode(default_encoding)
		if x['type'] == 'bt':
			bt.append((x['bt_hash'], x['id']))
		else:
			non_bt.append((x['original_url'], x['id']))
	if non_bt:
		urls, ids = zip(*non_bt)
		client.add_batch_tasks(urls, ids)
	for hash, id in bt:
		client.add_torrent_task_by_info_hash2(hash, id)
