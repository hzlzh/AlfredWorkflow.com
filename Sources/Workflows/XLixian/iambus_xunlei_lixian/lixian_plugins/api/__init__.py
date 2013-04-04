
__all__ = ['command', 'register_alias',
           'user_query', 'extract_info_hash_from_url', 'download_torrent_from_url',
           'task_filter', 'name_filter',
           'page_parser']

##################################################
# commands
##################################################

from lixian_plugins.commands import command

##################################################
# commands
##################################################

from lixian_alias import register_alias

##################################################
# queries
##################################################

from lixian_query import user_query

def extract_info_hash_from_url(regexp):
	import lixian_queries
	import re
	@user_query
	def processor(base, x):
		m = re.match(regexp, x)
		if m:
			return lixian_queries.BtHashQuery(base, m.group(1))

def download_torrent_from_url(regexp):
	import lixian_queries
	import re
	@user_query
	def processor(base, x):
		if re.match(regexp, x):
			return lixian_queries.bt_url_processor(base, x)

##################################################
# filters
##################################################

from lixian_plugins.filters import task_filter
from lixian_plugins.filters import name_filter

##################################################
# parsers
##################################################

def page_parser(pattern):
	def f(extend_links):
		import lixian_plugins.parsers
		patterns = pattern if type(pattern) is list else [pattern]
		for p in patterns:
			lixian_plugins.parsers.register_parser(p, extend_links)
	return f


##################################################
# download tools
##################################################

from lixian_download_tools import download_tool


