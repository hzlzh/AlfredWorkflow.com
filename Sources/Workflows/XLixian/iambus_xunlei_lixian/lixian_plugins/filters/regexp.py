
from lixian_plugins.api import name_filter

import re

@name_filter(protocol='regexp')
def filter_by_regexp(keyword, name):
	return re.search(keyword, name)
