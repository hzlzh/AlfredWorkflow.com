
__all__ = ['expand_command_line', 'parse_command_line', 'Parser', 'command_line_parse', 'command_line_option', 'command_line_value', 'command_line_parser', 'with_parser']

def expand_windows_command_line(args):
	from glob import glob
	expanded = []
	for x in args:
		try:
			xx = glob(x)
		except:
			xx = None
		if xx:
			expanded += xx
		else:
			expanded.append(x)
	return expanded

def expand_command_line(args):
	import platform
	return expand_windows_command_line(args) if platform.system() == 'Windows' else args

def parse_command_line(args, keys=[], bools=[], alias={}, default={}, help=None):
	args = expand_command_line(args)
	options = {}
	for k in keys:
		options[k] = None
	for k in bools:
		options[k] = None
	left = []
	args = args[:]
	while args:
		x = args.pop(0)
		if x == '--':
			left.extend(args)
			break
		if x.startswith('-') and len(x) > 1:
			k = x.lstrip('-')
			if k in bools:
				options[k] = True
			elif k.startswith('no-') and k[3:] in bools:
				options[k[3:]] = False
			elif k in keys:
				options[k] = args.pop(0)
			elif '=' in k and k[:k.index('=')] in keys:
				options[k[:k.index('=')]] = k[k.index('=')+1:]
			elif k in alias:
				k = alias[k]
				if k in bools:
					options[k] = True
				else:
					options[k] = args.pop(0)
			elif '=' in k and k[:k.index('=')] in alias:
				k, v = k[:k.index('=')], k[k.index('=')+1:]
				k = alias[k]
				if k not in keys:
					raise RuntimeError('Invalid boolean option '+x)
				options[k] = v
			else:
				if help:
					print 'Unknown option ' + x
					print
					print help
					exit(1)
				else:
					raise RuntimeError('Unknown option '+x)
		else:
			left.append(x)

	for k in default:
		if options[k] is None:
			options[k] = default[k]

	class Args(object):
		def __init__(self, args, left):
			self.__dict__['_args'] = args
			self.__dict__['_left'] = left
		def __getattr__(self, k):
			v = self._args.get(k, None)
			if v:
				return v
			if '_' in k:
				return self._args.get(k.replace('_', '-'), None)
		def __setattr__(self, k, v):
			self._args[k] = v
		def __getitem__(self, i):
			if type(i) == int:
				return self._left[i]
			else:
				return self._args[i]
		def __setitem__(self, i, v):
			if type(i) == int:
				self._left[i] = v
			else:
				self._args[i] = v
		def __len__(self):
			return len(self._left)
		def __str__(self):
			return '<Args%s%s>' % (self._args, self._left)
	return Args(options, left)

class Stack:
	def __init__(self, **args):
		self.__dict__.update(args)

class Parser:
	def __init__(self):
		self.stack = []
	def with_parser(self, parser):
		self.stack.append(parser)
		return self
	def __call__(self, args, keys=[], bools=[], alias={}, default={}, help=None):
		stack = Stack(keys=list(keys), bools=list(bools), alias=dict(alias), default=dict(default))
		keys = []
		bools = []
		alias = {}
		default = {}
		for stack in [x.args_stack for x in self.stack] + [stack]:
			keys += stack.keys
			bools += stack.bools
			alias.update(stack.alias)
			default.update(stack.default)
		args = parse_command_line(args, keys=keys, bools=bools, alias=alias, default=default, help=help)
		for fn in self.stack:
			new_args = fn(args)
			if new_args:
				args = new_args
		return args

def command_line_parse(keys=[], bools=[], alias={}, default={}):
	def wrapper(fn):
		if hasattr(fn, 'args_stack'):
			stack = fn.args_stack
			stack.keys += keys
			stack.bools += bools
			stack.alias.update(alias)
			stack.default.update(default)
		else:
			fn.args_stack = Stack(keys=list(keys), bools=list(bools), alias=dict(alias), default=dict(default))
		return fn
	return wrapper

def command_line_option(name, alias=None, default=None):
	alias = {alias:name} if alias else {}
	default = {name:default} if default is not None else {}
	return command_line_parse(bools=[name], alias=alias, default=default)

def command_line_value(name, alias=None, default=None):
	alias = {alias:name} if alias else {}
	default = {name:default} if default else {}
	return command_line_parse(keys=[name], alias=alias, default=default)

def command_line_parser(*args, **kwargs):
	def wrapper(f):
		parser = Parser()
		for x in reversed(getattr(f, 'args_parsers', [])):
			parser = parser.with_parser(x)
		if hasattr(f, 'args_stack'):
			def parse_no_body(args):
				pass
			parse_no_body.args_stack = f.args_stack
			parser = parser.with_parser(parse_no_body)
		import functools
		@functools.wraps(f)
		def parse(args_list):
			return f(parser(args_list, *args, **kwargs))
		return parse
	return wrapper

def with_parser(parser):
	def wrapper(f):
		if hasattr(f, 'args_parsers'):
			f.args_parsers.append(parser)
		else:
			f.args_parsers = [parser]
		return f
	return wrapper


