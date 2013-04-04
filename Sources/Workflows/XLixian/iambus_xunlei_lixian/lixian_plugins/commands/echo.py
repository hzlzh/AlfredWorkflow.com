
from lixian_plugins.api import command

@command(usage='echo arguments')
def echo(args):
	'''
	lx echo ...
	'''
	import lixian_cli_parser
	print ' '.join(lixian_cli_parser.expand_command_line(args))

