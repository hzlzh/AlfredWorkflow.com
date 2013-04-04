
from lixian_commands.util import *
import lixian_help

def lx_help(args):
	if len(args) == 1:
		helper = getattr(lixian_help, args[0].lower(), lixian_help.help)
		usage(helper)
	elif len(args) == 0:
		usage(lixian_help.welcome_help)
	else:
		usage(lixian_help.help)
