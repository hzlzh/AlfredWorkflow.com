
def load_plugins_at(dir):
	import os
	import os.path
	import re
	home = os.path.dirname(os.path.dirname(__file__))
	plugin_dir = os.path.join(home, dir.replace('.', '/'))
	plugins = os.listdir(plugin_dir)
	plugins = [re.sub(r'\.py$', '', p) for p in plugins if re.match(r'^[a-zA-Z]\w*\.py$', p)]
	for p in plugins:
		__import__(dir + '.' + p)

def load_plugins():
	load_plugins_at('lixian_plugins.commands')
	load_plugins_at('lixian_plugins.queries')
	load_plugins_at('lixian_plugins.filters')
	load_plugins_at('lixian_plugins.parsers')
	load_plugins_at('lixian_plugins')

load_plugins()
