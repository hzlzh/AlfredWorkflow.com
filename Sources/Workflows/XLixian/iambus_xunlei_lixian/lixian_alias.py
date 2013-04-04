

__all__ = ['register_alias', 'to_alias']

aliases = {'d': 'download', 'l': 'list', 'a': 'add', 'x': 'delete'}

def register_alias(alias, command):
	aliases[alias] = command

def get_aliases():
	return aliases

def get_alias(a):
	aliases = get_aliases()
	if a in aliases:
		return aliases[a]

def to_alias(a):
	return get_alias(a) or a

