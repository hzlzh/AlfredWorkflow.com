
from lixian_config import get_config
import sys

default_encoding = get_config('encoding', sys.getfilesystemencoding())
if default_encoding is None or default_encoding.lower() == 'ascii':
	default_encoding = 'utf-8'

