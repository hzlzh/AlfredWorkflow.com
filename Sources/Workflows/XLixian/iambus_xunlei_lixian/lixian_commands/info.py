

from lixian import XunleiClient
from lixian_commands.util import *
from lixian_cli_parser import *
import lixian_help

@command_line_parser(help=lixian_help.info)
@with_parser(parse_login)
@command_line_option('id', alias='i')
def lixian_info(args):
	client = XunleiClient(args.username, args.password, args.cookies, login=False)
	if args.id:
		print client.get_username()
	else:
		print 'id:', client.get_username()
		print 'internalid:', client.get_userid()
		print 'gdriveid:', client.get_gdriveid() or ''

