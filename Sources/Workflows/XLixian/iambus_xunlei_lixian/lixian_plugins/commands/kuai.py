
from lixian_plugins.api import command

@command(usage='parse links from kuai.xunlei.com')
def kuai(args):
	'''
	usage: lx kuai http://kuai.xunlei.com/d/xxx...

	Note that you can simply use:
	 lx add http://kuai.xunlei.com/d/xxx...
	or:
	 lx download http://kuai.xunlei.com/d/xxx...
	'''
	import lixian_kuai
	lixian_kuai.main(args)

