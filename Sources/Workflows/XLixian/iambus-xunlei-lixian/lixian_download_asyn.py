
import asyncore
import asynchat
import socket
import re
#from cStringIO import StringIO
from time import time, sleep
import sys
import os

#asynchat.async_chat.ac_out_buffer_size = 1024*1024

class http_client(asynchat.async_chat):

	def __init__(self, url, headers=None, start_from=0):
		asynchat.async_chat.__init__(self)

		self.args = {'headers': headers, 'start_from': start_from}

		m = re.match(r'http://([^/:]+)(?::(\d+))?(/.*)?$', url)
		assert m, 'Invalid url: %s' % url
		host, port, path = m.groups()
		port = int(port or 80)
		path = path or '/'
		if socket.gethostbyname(host) == '180.168.41.175':
			# fuck shanghai dian DNS
			self.log_error('gethostbyname failed')
			self.size = None
			return


		request_headers = {'host': host, 'connection': 'close'}
		if start_from:
			request_headers['RANGE'] = 'bytes=%d-' % start_from
		if headers:
			request_headers.update(headers)
		headers = request_headers
		self.request = 'GET %s HTTP/1.1\r\n%s\r\n\r\n' % (path, '\r\n'.join('%s: %s' % (k, headers[k]) for k in headers))
		self.op = 'GET'

		self.headers = {} # for response headers

		#self.buffer = StringIO()
		self.buffer = []
		self.buffer_size = 0
		self.cache_size = 1024*1024
		self.size = None
		self.completed = 0
		self.set_terminator("\r\n\r\n")
		self.reading_headers = True

		self.create_socket(socket.AF_INET, socket.SOCK_STREAM)
		try:
			self.connect((host, port))
		except:
			self.close()
			self.log_error('connect_failed')

	def handle_connect(self):
		self.start_time = time()
		self.push(self.request)

	def handle_close(self):
		asynchat.async_chat.handle_close(self)
		self.flush_data()
		if self.reading_headers:
			self.log_error('incomplete http response')
			return
		self.handle_status_update(self.size, self.completed, force_update=True)
		self.handle_speed_update(self.completed, self.start_time, force_update=True)
		if self.size is not None and self.completed < self.size:
			self.log_error('incomplete download')

	def handle_connection_error(self):
		self.handle_error()

	def handle_error(self):
		self.close()
		self.flush_data()
		error_message = sys.exc_info()[1]
		self.log_error('there is some error: %s' % error_message)
		#raise

	def collect_incoming_data(self, data):
		if self.reading_headers:
			#self.buffer.write(data)
			self.buffer.append(data)
			self.buffer_size += len(data)
			return
		elif self.cache_size:
			#self.buffer.write(data)
			self.buffer.append(data)
			self.buffer_size += len(data)
			#if self.buffer.tell() > self.cache_size:
			if self.buffer_size > self.cache_size:
				#self.handle_data(self.buffer.getvalue())
				self.handle_data(''.join(self.buffer))
				#self.buffer.truncate(0)
				#self.buffer.clear()
				del self.buffer[:]
				self.buffer_size = 0
		else:
			self.handle_data(data)

		self.completed += len(data)
		self.handle_status_update(self.size, self.completed)
		self.handle_speed_update(self.completed, self.start_time)
		if self.size == self.completed:
			self.close()
			self.flush_data()
			self.handle_status_update(self.size, self.completed, force_update=True)
			self.handle_speed_update(self.completed, self.start_time, force_update=True)

	def handle_data(self, data):
		print len(data)
		pass

	def flush_data(self):
		#if self.buffer.tell():
		if self.buffer_size:
			#self.handle_data(self.buffer.getvalue())
			self.handle_data(''.join(self.buffer))
			#self.buffer.truncate(0)
			del self.buffer[:]
			self.buffer_size = 0

	def parse_headers(self, header):
		lines = header.split('\r\n')
		status_line = lines.pop(0)
		#print status_line
		protocal, status_code, status_text = re.match(r'^HTTP/([\d.]+) (\d+) (.+)$', status_line).groups()
		status_code = int(status_code)
		self.status_code = status_code
		self.status_text = status_text
		#headers = dict(h.split(': ', 1) for h in lines)
		for k, v in (h.split(': ', 1) for h in lines):
			self.headers[k.lower()] = v

		if status_code in (200, 206):
			pass
		elif status_code == 302:
			return self.handle_http_relocate(self.headers['location'])
		else:
			return self.handle_http_status_error()

		self.size = self.headers.get('content-length', None)
		if self.size is not None:
			self.size = int(self.size)
		self.handle_http_headers()

	def found_terminator(self):
		if self.reading_headers:
			self.reading_headers = False
			#self.parse_headers("".join(self.buffer.getvalue()))
			self.parse_headers("".join(self.buffer))
			#self.buffer.truncate(0)
			del self.buffer[:]
			self.buffer_size = 0
			self.set_terminator(None)
		else:
			raise NotImplementedError()

	def handle_http_headers(self):
		pass

	def handle_http_status_error(self):
		self.close()

	def handle_http_relocate(self, location):
		self.close()
		relocate_times = getattr(self, 'relocate_times', 0)
		max_relocate_times = getattr(self, 'max_relocate_times', 2)
		if relocate_times >= max_relocate_times:
			raise Exception('too many relocate times')
		new_client = self.__class__(location, **self.args)
		new_client.relocate_times = relocate_times + 1
		new_client.max_relocate_times = max_relocate_times
		self.next_client = new_client

	def handle_status_update(self, total, completed, force_update=False):
		pass

	def handle_speed_update(self, completed, start_time, force_update=False):
		pass

	def log_error(self, message):
		print 'log_error', message
		self.error_message = message

class ProgressBar:
	def __init__(self, total=0):
		self.total = total
		self.completed = 0
		self.start = time()
		self.speed = 0
		self.bar_width = 0
		self.displayed = False
	def update(self):
		self.displayed = True
		bar_size = 40
		if self.total:
			percent = int(self.completed*100/self.total)
			if percent > 100:
				percent = 100
			dots = bar_size * percent / 100
			plus = percent - dots / bar_size * 100
			if plus > 0.8:
				plus = '='
			elif plus > 0.4:
				plu = '>'
			else:
				plus = ''
			bar = '=' * dots + plus
		else:
			percent = 0
			bar = '-'
		speed = self.speed
		if speed < 1000:
			speed = '%sB/s' % int(speed)
		elif speed < 1000*10:
			speed = '%.1fK/s' % (speed/1000.0)
		elif speed < 1000*1000:
			speed = '%dK/s' % int(speed/1000)
		elif speed < 1000*1000*100:
			speed = '%.1fM/s' % (speed/1000.0/1000.0)
		else:
			speed = '%dM/s' % int(speed/1000/1000)
		seconds = time() - self.start
		if seconds < 10:
			seconds = '%.1fs' % seconds
		elif seconds < 60:
			seconds = '%ds' % int(seconds)
		elif seconds < 60*60:
			seconds = '%dm%ds' % (int(seconds/60), int(seconds)%60)
		elif seconds < 60*60*24:
			seconds = '%dh%dm%ds' % (int(seconds)/60/60, (int(seconds)/60)%60, int(seconds)%60)
		else:
			seconds = int(seconds)
			days = seconds/60/60/24
			seconds -= days*60*60*24
			hours = seconds/60/60
			seconds -= hours*60*60
			minutes = seconds/60
			seconds -= minutes*60
			seconds = '%dd%dh%dm%ds' % (days, hours, minutes, seconds)
		completed = ','.join((x[::-1] for x in reversed(re.findall('..?.?', str(self.completed)[::-1]))))
		bar = '{0:>3}%[{1:<40}] {2:<12} {3:>4} in {4:>6s}'.format(percent, bar, completed, speed, seconds)
		new_bar_width = len(bar)
		bar = bar.ljust(self.bar_width)
		self.bar_width = new_bar_width
		sys.stdout.write('\r'+bar)
		sys.stdout.flush()
	def update_status(self, total, completed):
		self.total = total
		self.completed = completed
		self.update()
	def update_speed(self, start, speed):
		self.start = start
		self.speed = speed
		self.update()
	def done(self):
		if self.displayed:
			print
			self.displayed = False

def download(url, path, headers=None, resuming=False):
	class download_client(http_client):
		def __init__(self, url, headers=headers, start_from=0):
			self.output = None
			self.bar = ProgressBar()
			http_client.__init__(self, url, headers=headers, start_from=start_from)
			self.start_from = start_from
			self.last_status_time = time()
			self.last_speed_time = time()
			self.last_size = 0
			self.path = path
		def handle_close(self):
			http_client.handle_close(self)
			if self.output:
				self.output.close()
				self.output = None
		def handle_http_status_error(self):
			http_client.handle_http_status_error(self)
			self.log_error('http status error: %s, %s' % (self.status_code, self.status_text))
		def handle_data(self, data):
			if not self.output:
				if self.start_from:
					self.output = open(path, 'ab')
				else:
					self.output = open(path, 'wb')
			self.output.write(data)
		def handle_status_update(self, total, completed, force_update=False):
			if total is None:
				return
			if time() - self.last_status_time > 1 or force_update:
				#print '%.02f' % (completed*100.0/total)
				self.bar.update_status(total+start_from, completed+start_from)
				self.last_status_time = time()
		def handle_speed_update(self, completed, start_time, force_update=False):
			now = time()
			period = now - self.last_speed_time
			if period > 1 or force_update:
				#print '%.02f, %.02f' % ((completed-self.last_size)/period, completed/(now-start_time))
				self.bar.update_speed(start_time, (completed-self.last_size)/period)
				self.last_speed_time = time()
				self.last_size = completed
		def log_error(self, message):
			self.bar.done()
			http_client.log_error(self, message)
		def __del__(self): # XXX: sometimes handle_close() is not called, don't know why...
			#http_client.__del__(self)
			if self.output:
				self.output.close()
				self.output = None
	
	max_retry_times = 25
	retry_times = 0
	start_from = 0
	if resuming and os.path.exists(path):
		start_from = os.path.getsize(path)
		# TODO: fix status bar for resuming
	while True:
		client = download_client(url, start_from=start_from)
		asyncore.loop()
		while hasattr(client, 'next_client'):
			client = client.next_client
		client.bar.done()
		if getattr(client, 'error_message', None):
			retry_times += 1
			if retry_times >= max_retry_times:
				raise Exception(client.error_message)
			if client.size and client.completed:
				start_from = os.path.getsize(path)
			print 'retry', retry_times
			sleep(retry_times)
		else:
			break


def main():
	url, path = sys.argv[1:]
	download(url, path)

if __name__ == '__main__':
	main()

