
from lixian_plugins.api import command

@command(usage='parse links')
def extend_links(args):
	'''
	usage: lx extend-links http://kuai.xunlei.com/d/... http://www.verycd.com/topics/...

	parse and print links from pages

	lx extend-links urls...
	lx extend-links --name urls...
	'''

	from lixian_cli_parser import parse_command_line
	from lixian_encoding import default_encoding

	args = parse_command_line(args, [], ['name'])
	import lixian_plugins.parsers
	if args.name:
		for x in lixian_plugins.parsers.extend_links_name(args):
			print x.encode(default_encoding)
	else:
		for x in lixian_plugins.parsers.extend_links(args):
			print x

