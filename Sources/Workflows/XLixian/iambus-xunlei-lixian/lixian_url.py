
import base64
import urllib

def xunlei_url_encode(url):
	return 'thunder://'+base64.encodestring('AA'+url+'ZZ')

def xunlei_url_decode(url):
	assert url.startswith('thunder://')
	url = base64.decodestring(url[10:])
	assert url.startswith('AA') and url.endswith('ZZ')
	return url[2:-2]

def flashget_url_decode(encode):
	return 'Flashget://'+base64.encodestring('[FLASHGET]'+url+'[FLASHGET]')

def flashget_url_decode(url):
	assert url.startswith('Flashget://')
	url = base64.decodestring(url[11:])
	assert url.startswith('[FLASHGET]') and url.endswith('[FLASHGET]')
	return url.replace('[FLASHGET]', '')

def flashgetx_url_decode(url):
	assert url.startswith('flashgetx://|mhts|')
	name, size, hash, end = url.split('|')[2:]
	assert end == '/'
	return 'ed2k://|file|'+base64.decodestring(name)+'|'+size+'|'+hash+'/'

def qqdl_url_encode(url):
	return 'qqdl://' + base64.encodestring(url)

def qqdl_url_decode(url):
	assert url.startswith('qqdl://')
	return base64.decodestring(url[7:])

def url_unmask(url):
	if url.startswith('thunder://'):
		return normalize_unicode_link(xunlei_url_decode(url))
	elif url.startswith('Flashget://'):
		return flashget_url_decode(url)
	elif url.startswith('flashgetx://'):
		return flashgetx_url_decode(url)
	elif url.startswith('qqdl://'):
		return qqdl_url_decode(url)
	else:
		return url

def normalize_unicode_link(url):
	import re
	def escape_unicode(m):
		c = m.group()
		if ord(c) < 0x80:
			return c
		else:
			return urllib.quote(c.encode('utf-8'))
	def escape_str(m):
		c = m.group()
		if ord(c) < 0x80:
			return c
		else:
			return urllib.quote(c)
	if type(url) == unicode:
		return re.sub(r'.', escape_unicode, url)
	else:
		return re.sub(r'.', escape_str, url)
	return url

def unquote_url(x):
	x = urllib.unquote(x)
	if type(x) != str:
		return x
	try:
		return x.decode('utf-8')
	except UnicodeDecodeError:
		return x.decode('gbk') # can't decode in utf-8 and gbk

