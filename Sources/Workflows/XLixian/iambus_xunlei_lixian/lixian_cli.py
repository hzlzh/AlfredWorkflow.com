#!/usr/bin/env python

from lixian_commands.util import *
import lixian_help
import sys

from lixian_commands.login import login
from lixian_commands.logout import logout
from lixian_commands.download import download_task
from lixian_commands.list import list_task
from lixian_commands.add import add_task
from lixian_commands.delete import delete_task
from lixian_commands.pause import pause_task
from lixian_commands.restart import restart_task
from lixian_commands.rename import rename_task
from lixian_commands.readd import readd_task
from lixian_commands.info import lixian_info
from lixian_commands.config import lx_config
from lixian_commands.help import lx_help


def execute_command(args=sys.argv[1:]):
	import lixian_plugins # load plugins at import
	if not args:
		usage()
		sys.exit(1)
	command = args[0]
	if command.startswith('-'):
		if command in ('-h', '--help'):
			usage(lixian_help.welcome_help)
		elif command in ('-v', '--version'):
			print '0.0.x'
		else:
			usage()
			sys.exit(1)
		sys.exit(0)
	import lixian_alias
	command = lixian_alias.to_alias(command)
	commands = {'login': login,
	            'logout': logout,
	            'download': download_task,
	            'list': list_task,
	            'add': add_task,
	            'delete': delete_task,
	            'pause': pause_task,
	            'restart': restart_task,
	            'rename': rename_task,
	            'readd': readd_task,
	            'info': lixian_info,
	            'config': lx_config,
	            'help': lx_help}
	import lixian_plugins.commands
	commands.update(lixian_plugins.commands.commands)
	if command not in commands:
		usage()
		sys.exit(1)
	if '-h' in args or '--help' in args:
		lx_help([command])
	else:
		commands[command](args[1:])

if __name__ == '__main__':
	execute_command()


