

from lixian import encypt_password
from lixian_commands.util import *
from lixian_cli_parser import *
from lixian_config import *
import lixian_help
from getpass import getpass

@command_line_parser(help=lixian_help.config)
@command_line_option('print')
@command_line_option('delete')
def lx_config(args):
	if args.delete:
		assert len(args) == 1
		delete_config(args[0])
	elif args['print'] or not len(args):
		if len(args):
			assert len(args) == 1
			print get_config(args[0])
		else:
			print 'Loading', global_config.path, '...\n'
			print source_config()
			print global_config
	else:
		assert len(args) in (1, 2)
		if args[0] == 'password':
			if len(args) == 1 or args[1] == '-':
				password = getpass('Password: ')
			else:
				password = args[1]
			print 'Saving password (encrypted) to', global_config.path
			put_config('password', encypt_password(password))
		else:
			print 'Saving configuration to', global_config.path
			put_config(*args)
