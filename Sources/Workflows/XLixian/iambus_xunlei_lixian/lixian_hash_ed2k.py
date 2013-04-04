
import hashlib

chunk_size = 9728000
buffer_size = 1024*1024

def md4():
	return hashlib.new('md4')

def hash_stream(stream):
	total_md4 = None
	while True:
		chunk_md4 = md4()
		chunk_left = chunk_size
		while chunk_left:
			n = min(chunk_left, buffer_size)
			part = stream.read(n)
			chunk_md4.update(part)
			if len(part) < n:
				if total_md4:
					total_md4.update(chunk_md4.digest())
					return total_md4.hexdigest()
				else:
					return chunk_md4.hexdigest()
			chunk_left -= n
		if total_md4 is None:
			total_md4 = md4()
		total_md4.update(chunk_md4.digest())
	raise NotImplementedError()

def hash_string(s):
	from cStringIO import StringIO
	return hash_stream(StringIO(s))

def hash_file(path):
	with open(path, 'rb') as stream:
		return hash_stream(stream)

def parse_ed2k_link(link):
	import re, urllib
	ed2k_re = r'ed2k://\|file\|([^|]*)\|(\d+)\|([a-fA-F0-9]{32})\|'
	m = re.match(ed2k_re, link) or re.match(ed2k_re, urllib.unquote(link))
	if not m:
		raise Exception('not an acceptable ed2k link: '+link)
	name, file_size, hash_hex = m.groups()
	from lixian_url import unquote_url
	return unquote_url(name), hash_hex.lower(), int(file_size)

def parse_ed2k_id(link):
	return parse_ed2k_link(link)[1:]

def parse_ed2k_file(link):
	return parse_ed2k_link(link)[0]

def verify_ed2k_link(path, link):
	hash_hex, file_size = parse_ed2k_id(link)
	import os.path
	if os.path.getsize(path) != file_size:
		return False
	return hash_file(path).lower() == hash_hex.lower()

def generate_ed2k_link(path):
	import sys, os.path, urllib
	filename = os.path.basename(path)
	encoding = sys.getfilesystemencoding()
	if encoding.lower() != 'ascii':
		filename = filename.decode(encoding).encode('utf-8')
	return 'ed2k://|file|%s|%d|%s|/' % (urllib.quote(filename), os.path.getsize(path), hash_file(path))

def test_md4():
	assert hash_string("") == '31d6cfe0d16ae931b73c59d7e0c089c0'
	assert hash_string("a") == 'bde52cb31de33e46245e05fbdbd6fb24'
	assert hash_string("abc") == 'a448017aaf21d8525fc10ae87aa6729d'
	assert hash_string("message digest") == 'd9130a8164549fe818874806e1c7014b'
	assert hash_string("abcdefghijklmnopqrstuvwxyz") == 'd79e1c308aa5bbcdeea8ed63df412da9'
	assert hash_string("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789") == '043f8582f241db351ce627e153e7f0e4'
	assert hash_string("12345678901234567890123456789012345678901234567890123456789012345678901234567890") == 'e33b4ddc9c38f2199c3e7b164fcc0536'


