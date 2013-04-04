
from lixian_commands.util import *
from lixian_cli_parser import *
from lixian_config import get_config
import lixian_help
import lixian_query

@command_line_parser(help=lixian_help.add)
@with_parser(parse_login)
@with_parser(parse_colors)
@with_parser(parse_logging)
@with_parser(parse_size)
@command_line_value('input', alias='i')
@command_line_option('torrent', alias='bt')
def add_task(args):
	assert len(args) or args.input
	client = create_client(args)
	tasks = lixian_query.find_tasks_to_download(client, args)
	print 'All tasks added. Checking status...'
	columns = ['id', 'status', 'name']
	if get_config('n'):
		columns.insert(0, 'n')
	if args.size:
		columns.append('size')
	output_tasks(tasks, columns, args)
