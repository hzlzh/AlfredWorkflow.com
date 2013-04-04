
__all__ = ['WinConsole']

from lixian_colors_console import Console

import ctypes
from ctypes import windll, byref, Structure
from ctypes.wintypes import SHORT, WORD

import sys

INVALID_HANDLE_VALUE = -1
STD_OUTPUT_HANDLE = -11
STD_ERROR_HANDLE = -12

class COORD(Structure):
	_fields_ = (('X',  SHORT),
	            ('Y',  SHORT),)

class SMALL_RECT(Structure):
	_fields_ = (('Left',  SHORT),
	            ('Top',  SHORT),
	            ('Right',  SHORT),
	            ('Bottom',  SHORT),)

class CONSOLE_SCREEN_BUFFER_INFO(Structure):
	_fields_ = (('dwSize',  COORD),
	            ('dwCursorPosition',  COORD),
	            ('wAttributes',  WORD),
	            ('srWindow',  SMALL_RECT),
	            ('dwMaximumWindowSize',  COORD),)


def GetWinError():
	code = ctypes.GetLastError()
	message = ctypes.FormatError(code)
	return '[Error %s] %s' % (code, message)

def GetStdHandle(handle):
	h = windll.kernel32.GetStdHandle(handle)
	if h == INVALID_HANDLE_VALUE:
		raise OSError(GetWinError())
	return h

def GetConsoleScreenBufferInfo(handle):
	info = CONSOLE_SCREEN_BUFFER_INFO()
	if not windll.kernel32.GetConsoleScreenBufferInfo(handle, byref(info)):
		raise OSError(GetWinError())
	return info

def SetConsoleTextAttribute(handle, attributes):
	if not windll.Kernel32.SetConsoleTextAttribute(handle, attributes):
		raise OSError(GetWinError())


FOREGROUND_BLUE            = 0x0001
FOREGROUND_GREEN           = 0x0002
FOREGROUND_RED             = 0x0004
FOREGROUND_INTENSITY       = 0x0008
BACKGROUND_BLUE            = 0x0010
BACKGROUND_GREEN           = 0x0020
BACKGROUND_RED             = 0x0040
BACKGROUND_INTENSITY       = 0x0080
COMMON_LVB_LEADING_BYTE    = 0x0100
COMMON_LVB_TRAILING_BYTE   = 0x0200
COMMON_LVB_GRID_HORIZONTAL = 0x0400
COMMON_LVB_GRID_LVERTICAL  = 0x0800
COMMON_LVB_GRID_RVERTICAL  = 0x1000
COMMON_LVB_REVERSE_VIDEO   = 0x4000
COMMON_LVB_UNDERSCORE      = 0x8000

colors = {
	'black'  : 0b000,
	'blue'   : 0b001,
	'green'  : 0b010,
	'red'    : 0b100,
	'cyan'   : 0b011,
	'yellow' : 0b110,
	'purple' : 0b101,
	'magenta': 0b101,
	'white'  : 0b111,
}

def mix_styles(styles, attributes):
	fg_color = -1
	bg_color = -1
	fg_bright = -1
	bg_bright = -1
	reverse = -1
	underscore = -1
	for style in styles:
		if style == 0:
			# reset mode
			raise NotImplementedError()
		elif style == 1:
			# foreground bright on
			fg_bright = 1
		elif style == 2:
			# both bright off
			fg_bright = 0
			bg_bright = 0
		elif style == 4 or style == 'underline':
			# Underscore
			underscore = 1
		elif style == 5:
			# background bright on
			bg_bright = 1
		elif style == 7 or style == 'inverse':
			# Reverse foreground and background attributes.
			reverse = 1
		elif style == 21 or style == 22:
			# foreground bright off
			fg_bright = 0
		elif style == 24:
			# Underscore: no
			underscore = 0
		elif style == 25:
			# background bright off
			bg_bright = 0
		elif style == 27:
			# Reverse: no
			reverse = 0
		elif 30 <= style <= 37:
			# set foreground color
			fg_color = style - 30
		elif style == 39:
			# default text color
			fg_color = 7
			fg_bright = 0
		elif 40 <= style <= 47:
			# set background color
			bg_color = style - 40
		elif style == 49:
			# default background color
			bg_color = 0
		elif 90 <= style <= 97:
			# set bold foreground color
			fg_bright = 1
			fg_color = style - 90
		elif 100 <= style <= 107:
			# set bold background color
			bg_bright = 1
			bg_color = style - 100
		elif style == 'bold':
			fg_bright = 1
		elif style in colors:
			fg_color = colors[style]

	if fg_color != -1:
		attributes &= ~ 0b111
		attributes |= fg_color
	if fg_bright != -1:
		attributes &= ~ 0b1000
		attributes |= fg_bright << 3
	if bg_color != -1:
		attributes &= ~ 0b1110000
		attributes |= bg_color << 4
	if bg_bright != -1:
		attributes &= ~ 0b10000000
		attributes |= bg_bright << 7
	if reverse != -1:
		attributes &= ~ COMMON_LVB_REVERSE_VIDEO
		attributes |= reverse << 14
		# XXX: COMMON_LVB_REVERSE_VIDEO doesn't work...
		if reverse:
			attributes = (attributes & ~(0b11111111 | COMMON_LVB_REVERSE_VIDEO)) | ((attributes & 0b11110000) >> 4) | ((attributes & 0b1111) << 4)
	if underscore != -1:
		attributes &= ~ COMMON_LVB_UNDERSCORE
		attributes |= underscore << 15

	return attributes

class Render:
	def __init__(self, handle, default, attributes):
		self.handle = handle
		self.default = default
		self.attributes = attributes
	def __enter__(self):
		SetConsoleTextAttribute(self.handle, self.attributes)
	def __exit__(self, type, value, traceback):
		SetConsoleTextAttribute(self.handle, self.default)

class WinConsole(Console):
	def __init__(self, output=None, styles=[], handle=STD_OUTPUT_HANDLE):
		Console.__init__(self, output, styles)
		self.handle = GetStdHandle(handle)
		self.default = GetConsoleScreenBufferInfo(self.handle).wAttributes

	def write(self, s):
		if self.styles:
			with self.render(mix_styles(self.styles, self.default)):
				self.output.write(s)
				self.output.flush()
		else:
			self.output.write(s)
			self.output.flush()

	def render(self, attributes):
		return Render(self.handle, self.default, attributes)


