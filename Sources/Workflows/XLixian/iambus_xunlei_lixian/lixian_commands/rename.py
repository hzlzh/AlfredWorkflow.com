
from lixian_commands.util import *
from lixian_cli_parser import *
from lixian_encoding import from_native
import lixian_help
import re
import sys

@command_line_parser(help=lixian_help.rename)
@with_parser(parse_login)
@with_parser(parse_logging)
def rename_task(args):
	if len(args) != 2 or not re.match(r'\d+$', args[0]):
		usage(lixian_help.rename, 'Incorrect arguments')
		sys.exit(1)
	client = create_client(args)
	taskid, new_name = args
	task = client.get_task_by_id(taskid)
	client.rename_task(task, from_native(new_name))
