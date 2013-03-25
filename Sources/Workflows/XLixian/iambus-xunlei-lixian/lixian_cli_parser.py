
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
		if x.startswith('-'):
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

