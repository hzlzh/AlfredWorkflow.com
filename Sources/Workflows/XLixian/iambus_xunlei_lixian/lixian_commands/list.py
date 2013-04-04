
from lixian_commands.util import *
from lixian_cli_parser import *
from lixian_config import get_config
import lixian_help
import lixian_query
import re

@command_line_parser(help=lixian_help.list)
@with_parser(parse_login)
@with_parser(parse_colors)
@with_parser(parse_logging)
@with_parser(parse_size)
@command_line_option('all', default=True)
@command_line_option('completed')
@command_line_option('deleted')
@command_line_option('expired')
@command_line_value('category')
@command_line_option('id', default=get_config('id', True))
@command_line_option('name', default=True)
@command_line_option('status', default=True)
@command_line_option('dcid')
@command_line_option('gcid')
@command_line_option('original-url')
@command_line_option('download-url')
@command_line_option('speed')
@command_line_option('progress')
@command_line_option('date')
@command_line_option('n', default=get_config('n'))
def list_task(args):

	parent_ids = [a[:-1] for a in args if re.match(r'^#?\d+/$', a)]
	if parent_ids and not all(re.match(r'^#?\d+/$', a) for a in args):
		raise NotImplementedError("Can't mix 'id/' with others")
	assert len(parent_ids) <= 1, "sub-tasks listing only supports single task id"
	ids = [a[:-1] if re.match(r'^#?\d+/$', a) else a for a in args]

	client = create_client(args)
	if parent_ids:
		args[0] = args[0][:-1]
		tasks = lixian_query.search_tasks(client, args)
		assert len(tasks) == 1
		tasks = client.list_bt(tasks[0])
		#tasks = client.list_bt(client.get_task_by_id(parent_ids[0]))
		tasks.sort(key=lambda x: int(x['index']))
	else:
		tasks = lixian_query.search_tasks(client, args)
		if len(args) == 1 and re.match(r'\d+/', args[0]) and len(tasks) == 1 and 'files' in tasks[0]:
			parent_ids = [tasks[0]['id']]
			tasks = tasks[0]['files']
	columns = ['n', 'id', 'name', 'status', 'size', 'progress', 'speed', 'date', 'dcid', 'gcid', 'original-url', 'download-url']
	columns = filter(lambda k: getattr(args, k), columns)

	output_tasks(tasks, columns, args, not parent_ids)
