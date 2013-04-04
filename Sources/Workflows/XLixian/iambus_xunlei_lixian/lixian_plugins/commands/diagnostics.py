
from lixian_plugins.api import command

@command(name='diagnostics', usage='print helpful information for diagnostics')
def lx_diagnostics(args):
	'''
	usage: lx diagnostics
	'''
	from lixian_encoding import default_encoding
	print 'default_encoding ->', default_encoding
	import sys
	print 'sys.getdefaultencoding() ->', sys.getdefaultencoding()
	print 'sys.getfilesystemencoding() ->', sys.getfilesystemencoding()
	print r"print u'\u4e2d\u6587'.encode('utf-8') ->", u'\u4e2d\u6587'.encode('utf-8')
	print r"print u'\u4e2d\u6587'.encode('gbk') ->", u'\u4e2d\u6587'.encode('gbk')

