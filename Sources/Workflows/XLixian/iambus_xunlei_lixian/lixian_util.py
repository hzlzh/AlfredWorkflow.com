
__all__ = []

import re

def format_1d(n):
	return re.sub(r'\.0*$', '', '%.1f' % n)

def format_size(n):
	if n < 1000:
		return '%sB' % n
	elif n < 1000**2:
		return '%sK' % format_1d(n/1000.)
	elif n < 1000**3:
		return '%sM' % format_1d(n/1000.**2)
	elif n < 1000**4:
		return '%sG' % format_1d(n/1000.**3)


