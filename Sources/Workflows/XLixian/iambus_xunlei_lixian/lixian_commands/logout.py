
from lixian import XunleiClient
from lixian_commands.util import *
from lixian_cli_parser import *
import lixian_config
import lixian_help

@command_line_parser(help=lixian_help.logout)
@with_parser(parse_logging)
@command_line_value('cookies', default=lixian_config.LIXIAN_DEFAULT_COOKIES)
def logout(args):
	if len(args):
		raise RuntimeError('Too many arguments')
	print 'logging out from', args.cookies
	assert args.cookies
	client = XunleiClient(cookie_path=args.cookies, login=False)
	client.logout()

