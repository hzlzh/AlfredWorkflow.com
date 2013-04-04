
__all__ = ['Console']

import sys

styles = [
	'black',
	'blue',
	'green',
	'red',
	'cyan',
	'yellow',
	'purple',
	'white',

	'bold',
	'italic',
	'underline',
	'inverse',
]


class Console:
	def __init__(self, output=None, styles=[]):
		output = output or sys.stdout
		if isinstance(output, Console):
			self.output = output.output
			self.styles = output.styles + styles
		else:
			self.output = output
			self.styles = styles
		assert not isinstance(self.output, Console)
	def __getattr__(self, name):
		if name in styles:
			return self.ansi(name)
		else:
			raise AttributeError(name)
	def ansi(self, code):
		return self.__class__(self.output, self.styles + [code]) if code not in (None, '') else self
	def __call__(self, s):
		self.write(s)
	def write(self, s):
		self.output.write(s)
	def flush(self, *args):
		self.output.flush(*args)

