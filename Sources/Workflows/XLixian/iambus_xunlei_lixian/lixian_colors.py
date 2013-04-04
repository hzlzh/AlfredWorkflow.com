
import os
import sys

def get_console_type(use_colors=True):
	if use_colors and sys.stdout.isatty() and sys.stderr.isatty():
		import platform
		if platform.system() == 'Windows':
			import lixian_colors_win32
			return lixian_colors_win32.WinConsole
		else:
			import lixian_colors_linux
			return lixian_colors_linux.AnsiConsole
	else:
		import lixian_colors_console
		return lixian_colors_console.Console

console_type = get_console_type()
raw_console_type = get_console_type(False)

def Console(use_colors=True):
	return get_console_type(use_colors)()

def get_softspace(output):
	if hasattr(output, 'softspace'):
		return output.softspace
	import lixian_colors_console
	if isinstance(output, lixian_colors_console.Console):
		return get_softspace(output.output)
	return 0

class ScopedColors(console_type):
	def __init__(self, *args):
		console_type.__init__(self, *args)
	def __call__(self):
		console = self
		class Scoped:
			def __enter__(self):
				self.stdout = sys.stdout
				softspace = get_softspace(sys.stdout)
				sys.stdout = console
				sys.stdout.softspace = softspace
			def __exit__(self, type, value, traceback):
				softspace = get_softspace(sys.stdout)
				sys.stdout = self.stdout
				sys.stdout.softspace = softspace
		return Scoped()

class RawScopedColors(raw_console_type):
	def __init__(self, *args):
		raw_console_type.__init__(self, *args)
	def __call__(self):
		class Scoped:
			def __enter__(self):
				pass
			def __exit__(self, type, value, traceback):
				pass
		return Scoped()

class RootColors:
	def __init__(self, use_colors=True):
		self.use_colors = use_colors
	def __getattr__(self, name):
		return getattr(ScopedColors() if self.use_colors else RawScopedColors(), name)
	def __call__(self, use_colors):
		assert use_colors in (True, False, None), use_colors
		return RootColors(use_colors)

colors = RootColors()

