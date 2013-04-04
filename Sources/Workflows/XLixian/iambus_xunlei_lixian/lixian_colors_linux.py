
__all__ = ['AnsiConsole']

from lixian_colors_console import Console

import sys

colors = {
	'bold' : [1, 22],
	'italic' : [3, 23],
	'underline' : [4, 24],
	'inverse' : [7, 27],
	'white' : [37, 39],
	'grey' : [90, 39],
	'black' : [30, 39],
	'blue' : [34, 39],
	'cyan' : [36, 39],
	'green' : [32, 39],
	'purple' : [35, 39],
	'magenta' : [35, 39],
	'red' : [31, 39],
	'yellow' : [33, 39]
}

class Render:
	def __init__(self, output, code):
		self.output = output
		self.left, self.right = code
	def __enter__(self):
		self.output.write(self.left)
		self.output.flush()
	def __exit__(self, type, value, traceback):
		self.output.write(self.right)
		self.output.flush()

def mix_styles(styles):
	left = []
	right = []
	for style in styles:
		if style in colors:
			color = colors[style]
			left.append(color[0])
			right.append(color[1])
	right.reverse()
	return [''.join('\033[%dm' % n for n in left), ''.join('\033[%dm' % n for n in right)]

class AnsiConsole(Console):
	def __init__(self, output=None, styles=[]):
		Console.__init__(self, output, styles)

	def write(self, s):
		if self.styles:
			with self.render(mix_styles(self.styles)):
				self.output.write(s)
				self.output.flush()
		else:
			self.output.write(s)
			self.output.flush()

	def render(self, code):
		return Render(self.output, code)

