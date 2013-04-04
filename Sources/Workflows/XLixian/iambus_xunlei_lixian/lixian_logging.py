
__all__ = ['init_logger', 'get_logger']

import logging

INFO = logging.INFO
DEBUG = logging.DEBUG
TRACE = 1

def file_logger(path, level):
	import os.path
	path = os.path.expanduser(path)

	logger = logging.getLogger('lixian')
	logger.setLevel(min(level, DEBUG)) # if file log is enabled, always log debug message

	handler = logging.FileHandler(filename=path, )
	handler.setFormatter(logging.Formatter('%(asctime)s %(message)s'))

	logger.addHandler(handler)

	return logger

class ConsoleLogger:
	def __init__(self, level=INFO):
		self.level = level
	def stdout(self, message):
		print message
	def info(self, message):
		if self.level <= INFO:
			print message
	def debug(self, message):
		if self.level <= DEBUG:
			print message
	def trace(self, message):
		pass

class FileLogger:
	def __init__(self, path, level=INFO, file_level=None, console_level=None):
		console_level = console_level or level
		file_level = file_level or level
		self.console = ConsoleLogger(console_level)
		self.logger = file_logger(path, file_level)
	def stdout(self, message):
		self.console.stdout(message)
	def info(self, message):
		self.console.info(message)
		self.logger.info(message)
	def debug(self, message):
		self.console.debug(message)
		self.logger.debug(message)
	def trace(self, message):
		self.logger.log(level=TRACE, msg=message)

default_logger = None

def init_logger(use_colors=True, level=INFO, path=None):
	global default_logger
	if not default_logger:
		if isinstance(level, int):
			assert level in (INFO, DEBUG, TRACE)
			console_level = level
			file_level = level
		elif isinstance(level, basestring):
			level = level.lower()
			if level in ('info', 'debug', 'trace'):
				level = {'info': INFO, 'debug': DEBUG, 'trace': TRACE}[level]
				console_level = level
				file_level = level
			else:
				console_level = INFO
				file_level = DEBUG
				for level in level.split(','):
					device, level = level.split(':')
					if device == 'console':
						console_level = {'info': INFO, 'debug': DEBUG, 'trace': TRACE}[level]
					elif device == 'file':
						file_level = {'info': INFO, 'debug': DEBUG, 'trace': TRACE}[level]
					else:
						raise NotImplementedError('Invalid logging level: ' + device)
		else:
			raise NotImplementedError(type(level))
		if path:
			default_logger = FileLogger(path, console_level=console_level, file_level=file_level)
		else:
			default_logger = ConsoleLogger(console_level)

def get_logger():
	init_logger()
	return default_logger

