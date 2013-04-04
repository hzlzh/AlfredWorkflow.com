
from lixian_config import get_config
import sys

default_encoding = get_config('encoding', sys.getfilesystemencoding())
if default_encoding is None or default_encoding.lower() == 'ascii':
	default_encoding = 'utf-8'


def to_native(s):
	if type(s) == unicode:
		return s.encode(default_encoding)
	else:
		return s

def from_native(s):
	if type(s) == str:
		return s.decode(default_encoding)
	else:
		return s

def try_native_to_utf_8(url):
	try:
		return url.decode(default_encoding).encode('utf-8')
	except:
		return url

