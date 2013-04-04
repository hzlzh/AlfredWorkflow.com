
from lixian_plugins.api import command

@command(usage='convert thunder:// (and more) to normal url')
def decode_url(args):
	'''
	usage: lx decode-url thunder://...
	'''
	from lixian_url import url_unmask
	for x in args:
		print url_unmask(x)

