
from lixian_commands.util import *
from lixian_cli_parser import *
from lixian_encoding import default_encoding
import lixian_help
import lixian_query

@command_line_parser(help=lixian_help.pause)
@with_parser(parse_login)
@with_parser(parse_colors)
@with_parser(parse_logging)
@command_line_option('i')
@command_line_option('all')
def pause_task(args):
	client = create_client(args)
	to_pause = lixian_query.search_tasks(client, args)
	print "Below files are going to be paused:"
	for x in to_pause:
		print x['name'].encode(default_encoding)
	client.pause_tasks(to_pause)
