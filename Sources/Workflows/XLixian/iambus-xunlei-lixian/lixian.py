
__all__ = ['XunleiClient']

import urllib
import urllib2
import cookielib
import re
import time
import os.path
import json
from ast import literal_eval

def retry(f):
	#retry_sleeps = [1, 1, 1]
	retry_sleeps = [1, 2, 3, 5, 10, 20, 30, 60] + [60] * 60
	def withretry(*args, **kwargs):
		for second in retry_sleeps:
			try:
				return f(*args, **kwargs)
			except:
				import traceback
				import sys
				print "Exception in user code:"
				traceback.print_exc(file=sys.stdout)
				time.sleep(second)
		raise
	return withretry

class XunleiClient:
	def __init__(self, username=None, password=None, cookie_path=None, login=True):
		self.cookie_path = cookie_path
		if cookie_path:
			self.cookiejar = cookielib.LWPCookieJar()
			if os.path.exists(cookie_path):
				self.load_cookies()
		else:
			self.cookiejar = cookielib.CookieJar()
		self.set_page_size(9999)
		self.opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(self.cookiejar))
		if login:
			if not self.has_logged_in():
				if not username and self.has_cookie('.xunlei.com', 'usernewno'):
					username = self.get_username()
				if not username:
					import lixian_config
					username = lixian_config.get_config('username')
#				if not username:
#					raise NotImplementedError('user is not logged in')
				if not password:
					raise NotImplementedError('user is not logged in')
				self.login(username, password)
			else:
				self.id = self.get_userid()

	@retry
	def urlopen(self, url, **args):
		#print url
		if 'data' in args and type(args['data']) == dict:
			args['data'] = urlencode(args['data'])
		return self.opener.open(urllib2.Request(url, **args), timeout=60)

	def urlread(self, url, **args):
		args.setdefault('headers', {})
		headers = args['headers']
		headers.setdefault('Accept-Encoding', 'gzip, deflate')
#		headers.setdefault('Referer', 'http://lixian.vip.xunlei.com/task.html')
#		headers.setdefault('User-Agent', 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:11.0) Gecko/20100101 Firefox/11.0')
#		headers.setdefault('Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8')
#		headers.setdefault('Accept-Language', 'zh-cn,zh;q=0.7,en-us;q=0.3')
		response = self.urlopen(url, **args)
		data = response.read()
		if response.info().get('Content-Encoding') == 'gzip':
			data = ungzip(data)
		elif response.info().get('Content-Encoding') == 'deflate':
			data = undeflate(data)
		return data

	def load_cookies(self):
		self.cookiejar.load(self.cookie_path, ignore_discard=True, ignore_expires=True)

	def save_cookies(self):
		if self.cookie_path:
			self.cookiejar.save(self.cookie_path, ignore_discard=True)

	def get_cookie(self, domain, k):
		if self.has_cookie(domain, k):
			return self.cookiejar._cookies[domain]['/'][k].value

	def has_cookie(self, domain, k):
		return domain in self.cookiejar._cookies and k in self.cookiejar._cookies[domain]['/']

	def get_userid(self):
		if self.has_cookie('.xunlei.com', 'userid'):
			return self.get_cookie('.xunlei.com', 'userid')
		else:
			raise Exception('Probably login failed')

	def get_userid_or_none(self):
		return self.get_cookie('.xunlei.com', 'userid')

	def get_username(self):
		return self.get_cookie('.xunlei.com', 'usernewno')

	def get_gdriveid(self):
		return self.get_cookie('.vip.xunlei.com', 'gdriveid')

	def has_gdriveid(self):
		return self.has_cookie('.vip.xunlei.com', 'gdriveid')

	def get_referer(self):
		return 'http://dynamic.cloud.vip.xunlei.com/user_task?userid=%s' % self.id

	def set_cookie(self, domain, k, v):
		c = cookielib.Cookie(version=0, name=k, value=v, port=None, port_specified=False, domain=domain, domain_specified=True, domain_initial_dot=False, path='/', path_specified=True, secure=False, expires=None, discard=True, comment=None, comment_url=None, rest={}, rfc2109=False)
		self.cookiejar.set_cookie(c)

	def set_gdriveid(self, id):
		self.set_cookie('.vip.xunlei.com', 'gdriveid', id)

	def set_page_size(self, n):
		self.set_cookie('.vip.xunlei.com', 'pagenum', str(n))

	def get_cookie_header(self):
		def domain_header(domain):
			root = self.cookiejar._cookies[domain]['/']
			return '; '.join(k+'='+root[k].value for k in root)
		return  domain_header('.xunlei.com') + '; ' + domain_header('.vip.xunlei.com')

	def is_login_ok(self, html):
		return len(html) > 512

	def has_logged_in(self):
		id = self.get_userid_or_none()
		if not id:
			return False
		#print self.urlopen('http://dynamic.cloud.vip.xunlei.com/user_task?userid=%s&st=0' % id).read().decode('utf-8')
		self.set_page_size(1)
		url = 'http://dynamic.cloud.vip.xunlei.com/user_task?userid=%s&st=0' % id
		#url = 'http://dynamic.lixian.vip.xunlei.com/login?cachetime=%d' % current_timestamp()
		r = self.is_login_ok(self.urlread(url))
		self.set_page_size(9999)
		return r

	def login(self, username, password):
		cachetime = current_timestamp()
		check_url = 'http://login.xunlei.com/check?u=%s&cachetime=%d' % (username, cachetime)
		login_page = self.urlopen(check_url).read()
		verifycode = self.get_cookie('.xunlei.com', 'check_result')[2:].upper()
		password = encypt_password(password)
		password = md5(password+verifycode)
		login_page = self.urlopen('http://login.xunlei.com/sec2login/', data={'u': username, 'p': password, 'verifycode': verifycode})
		self.id = self.get_userid()
		self.set_page_size(1)
		login_page = self.urlopen('http://dynamic.lixian.vip.xunlei.com/login?cachetime=%d&from=0'%current_timestamp()).read()
		self.set_page_size(9999)
		assert self.is_login_ok(login_page), 'login failed'
		self.save_cookies()

	def logout(self):
		#session_id = self.get_cookie('.xunlei.com', 'sessionid')
		#timestamp = current_timestamp()
		#url = 'http://login.xunlei.com/unregister?sessionid=%s&cachetime=%s&noCacheIE=%s' % (session_id, timestamp, timestamp)
		#self.urlopen(url).read()
		#self.urlopen('http://dynamic.vip.xunlei.com/login/indexlogin_contr/logout/').read()
		ckeys = ["vip_isvip","lx_sessionid","vip_level","lx_login","dl_enable","in_xl","ucid","lixian_section"]
		ckeys1 = ["sessionid","usrname","nickname","usernewno","userid"]
		for k in ckeys:
			self.set_cookie('.vip.xunlei.com', k, '')
		for k in ckeys1:
			self.set_cookie('.xunlei.com', k, '')
		self.save_cookies()

	def read_task_page_url(self, url):
		page = self.urlread(url).decode('utf-8', 'ignore')
		if not self.has_gdriveid():
			gdriveid = re.search(r'id="cok" value="([^"]+)"', page).group(1)
			self.set_gdriveid(gdriveid)
			self.save_cookies()
		tasks = parse_tasks(page)
		for t in tasks:
			t['client'] = self
		pginfo = re.search(r'<div class="pginfo">.*?</div>', page)
		match_next_page = re.search(r'<li class="next"><a href="([^"]+)">[^<>]*</a></li>', page)
		return tasks, match_next_page and 'http://dynamic.cloud.vip.xunlei.com'+match_next_page.group(1)

	def read_task_page(self, st, pg=None):
		if pg is None:
			url = 'http://dynamic.cloud.vip.xunlei.com/user_task?userid=%s&st=%d' % (self.id, st)
		else:
			url = 'http://dynamic.cloud.vip.xunlei.com/user_task?userid=%s&st=%d&p=%d' % (self.id, st, pg)
		return self.read_task_page_url(url)

	def read_tasks(self, st=0):
		tasks = self.read_task_page(st)[0]
		for i, task in enumerate(tasks):
			task['#'] = i
		return tasks

	def read_all_tasks(self, st=0):
		all_tasks = []
		tasks, next_link = self.read_task_page(st)
		all_tasks.extend(tasks)
		while next_link:
			tasks, next_link = self.read_task_page_url(next_link)
			all_tasks.extend(tasks)
		for i, task in enumerate(all_tasks):
			task['#'] = i
		return all_tasks

	def read_completed(self):
		return self.read_tasks(2)

	def read_all_completed(self):
		return self.read_all_tasks(2)

	def list_bt(self, task):
		url = 'http://dynamic.cloud.vip.xunlei.com/interface/fill_bt_list?callback=fill_bt_list&tid=%s&infoid=%s&g_net=1&p=1&uid=%s&noCacheIE=%s' % (task['id'], task['bt_hash'], self.id, current_timestamp())
		html = remove_bom(self.urlread(url)).decode('utf-8')
		sub_tasks = parse_bt_list(html)
		for t in sub_tasks:
			t['date'] = task['date']
		return sub_tasks

	def get_torrent_file_by_info_hash(self, info_hash):
		url = 'http://dynamic.cloud.vip.xunlei.com/interface/get_torrent?userid=%s&infoid=%s' % (self.id, info_hash.upper())
		response = self.urlopen(url)
		torrent = response.read()
		if torrent == "<meta http-equiv='Content-Type' content='text/html; charset=utf-8' /><script>alert('\xe5\xaf\xb9\xe4\xb8\x8d\xe8\xb5\xb7\xef\xbc\x8c\xe6\xb2\xa1\xe6\x9c\x89\xe6\x89\xbe\xe5\x88\xb0\xe5\xaf\xb9\xe5\xba\x94\xe7\x9a\x84\xe7\xa7\x8d\xe5\xad\x90\xe6\x96\x87\xe4\xbb\xb6!');</script>":
			raise Exception('Torrent file not found on xunlei cloud: '+info_hash)
		assert response.headers['content-type'] == 'application/octet-stream'
		return torrent

	def get_torrent_file(self, task):
		return self.get_torrent_file_by_info_hash(task['bt_hash'])

	def add_task(self, url):
		protocol = parse_url_protocol(url)
		assert protocol in ('ed2k', 'http', 'ftp', 'thunder', 'Flashget', 'qqdl', 'bt', 'magnet'), 'protocol "%s" is not suppoted' % protocol

		from lixian_url import url_unmask
		url = url_unmask(url)
		protocol = parse_url_protocol(url)
		assert protocol in ('ed2k', 'http', 'ftp', 'bt', 'magnet'), 'protocol "%s" is not suppoted' % protocol

		if protocol == 'bt':
			return self.add_torrent_task_by_info_hash(url[5:])
		elif protocol == 'magnet':
			return self.add_magnet_task(url)

		random = current_random()
		check_url = 'http://dynamic.cloud.vip.xunlei.com/interface/task_check?callback=queryCid&url=%s&random=%s&tcache=%s' % (urllib.quote(url), random, current_timestamp())
		js = self.urlopen(check_url).read().decode('utf-8')
		qcid = re.match(r'^queryCid(\(.+\))\s*$', js).group(1)
		qcid = literal_eval(qcid)
		if len(qcid) == 8:
			cid, gcid, size_required, filename, goldbean_need, silverbean_need, is_full, random = qcid
		elif len(qcid) == 9:
			cid, gcid, size_required, filename, goldbean_need, silverbean_need, is_full, random, ext = qcid
		elif len(qcid) == 10:
			cid, gcid, size_required, some_key, filename, goldbean_need, silverbean_need, is_full, random, ext = qcid
		else:
			raise NotImplementedError(qcid)
		assert goldbean_need == 0
		assert silverbean_need == 0

		if url.startswith('http://') or url.startswith('ftp://'):
			task_type = 0
		elif url.startswith('ed2k://'):
			task_type = 2
		else:
			raise NotImplementedError()
		task_url = 'http://dynamic.cloud.vip.xunlei.com/interface/task_commit?'+urlencode(
		   {'callback': 'ret_task',
		    'uid': self.id,
		    'cid': cid,
		    'gcid': gcid,
		    'size': size_required,
		    'goldbean': goldbean_need,
		    'silverbean': silverbean_need,
		    't': filename,
		    'url': url,
			'type': task_type,
		    'o_page': 'task',
		    'o_taskid': '0',
		    })

		response = self.urlopen(task_url).read()
		assert response == 'ret_task(Array)', response

	def add_batch_tasks(self, urls):
		assert urls
		urls = list(urls)
		for url in urls:
			if parse_url_protocol(url) not in ('http', 'ftp', 'ed2k', 'bt', 'thunder', 'magnet'):
				raise NotImplementedError('Unsupported: '+url)
		urls = filter(lambda u: parse_url_protocol(u) in ('http', 'ftp', 'ed2k', 'thunder'), urls)
		if not urls:
			return
		#self.urlopen('http://dynamic.cloud.vip.xunlei.com/interface/batch_task_check', data={'url':'\r\n'.join(urls), 'random':current_random()})
		jsonp = 'jsonp%s' % current_timestamp()
		url = 'http://dynamic.cloud.vip.xunlei.com/interface/batch_task_commit?callback=%s' % jsonp
		batch_old_taskid = '0' + ',' * (len(urls) - 1) # XXX: what is it?
		data = {}
		for i in range(len(urls)):
			data['cid[%d]' % i] = ''
			data['url[%d]' % i] = urllib.quote(urls[i]) # fix per request #98
		data['batch_old_taskid'] = batch_old_taskid
		response = self.urlopen(url, data=data).read()
		assert_response(response, jsonp)

	def add_torrent_task_by_content(self, content, path='attachment.torrent'):
		assert content.startswith('d8:announce') or content.startswith('d13:announce-list'), 'Probably not a valid torrent file [%s...]' % repr(content[:17])
		upload_url = 'http://dynamic.cloud.vip.xunlei.com/interface/torrent_upload'
		jsonp = 'jsonp%s' % current_timestamp()
		commit_url = 'http://dynamic.cloud.vip.xunlei.com/interface/bt_task_commit?callback=%s' % jsonp

		content_type, body = encode_multipart_formdata([], [('filepath', path, content)])

		response = self.urlopen(upload_url, data=body, headers={'Content-Type': content_type}).read().decode('utf-8')

		upload_success = re.search(r'<script>document\.domain="xunlei\.com";var btResult =(\{.*\});</script>', response, flags=re.S)
		if upload_success:
			bt = json.loads(upload_success.group(1))
			bt_hash = bt['infoid']
			bt_name = bt['ftitle']
			bt_size = bt['btsize']
			data = {'uid':self.id, 'btname':bt_name, 'cid':bt_hash, 'tsize':bt_size,
					'findex':''.join(f['id']+'_' for f in bt['filelist']),
					'size':''.join(f['subsize']+'_' for f in bt['filelist']),
					'from':'0'}
			response = self.urlopen(commit_url, data=data).read()
			assert_response(response, jsonp)
			return bt_hash
		already_exists = re.search(r"parent\.edit_bt_list\((\{.*\}),''\)", response, flags=re.S)
		if already_exists:
			bt = json.loads(already_exists.group(1))
			bt_hash = bt['infoid']
			return bt_hash
		raise NotImplementedError()

	def add_torrent_task_by_info_hash(self, sha1):
		return self.add_torrent_task_by_content(self.get_torrent_file_by_info_hash(sha1), sha1.upper()+'.torrent')

	def add_torrent_task(self, path):
		with open(path, 'rb') as x:
			return self.add_torrent_task_by_content(x.read(), os.path.basename(path))

	def add_magnet_task(self, link):
		url = 'http://dynamic.cloud.vip.xunlei.com/interface/url_query?callback=queryUrl&u=%s&random=%s' % (urllib.quote(link), current_timestamp())
		response = self.urlopen(url).read()
		success = re.search(r'queryUrl(\(1,.*\))\s*$', response, flags=re.S)
		if not success:
			already_exists = re.search(r"queryUrl\(-1,'([^']{40})", response, flags=re.S)
			if already_exists:
				return already_exists.group(1)
			raise NotImplementedError(repr(response))
		args = success.group(1).decode('utf-8')
		args = literal_eval(args.replace('new Array', ''))
		_, cid, tsize, btname, _, names, sizes_, sizes, _, types, findexes, timestamp = args
		def toList(x):
			if type(x) in (list, tuple):
				return x
			else:
				return [x]
		data = {'uid':self.id, 'btname':btname, 'cid':cid, 'tsize':tsize,
				'findex':''.join(x+'_' for x in toList(findexes)),
				'size':''.join(x+'_' for x in toList(sizes)),
				'from':'0'}
		jsonp = 'jsonp%s' % current_timestamp()
		commit_url = 'http://dynamic.cloud.vip.xunlei.com/interface/bt_task_commit?callback=%s' % jsonp
		response = self.urlopen(commit_url, data=data).read()
		assert_response(response, jsonp)
		return cid

	def delete_tasks_by_id(self, ids):
		url = 'http://dynamic.cloud.vip.xunlei.com/interface/task_delete?type=%s&taskids=%s&databases=0,&noCacheIE=%s' % (2, ','.join(ids)+',', current_timestamp()) # XXX: what is 'type'?
		response = self.urlopen(url).read()
		response = remove_bom(response)
		response = json.loads(re.match(r'^delete_task_resp\((.+)\)$', response).group(1))
		assert response['result'] == 1
		assert response['type'] == 2

	def delete_task_by_id(self, id):
		self.delete_tasks_by_id([id])

	def delete_task(self, task):
		self.delete_task_by_id(task['id'])

	def delete_tasks(self, tasks):
		self.delete_tasks_by_id([t['id'] for t in tasks])

	def pause_tasks_by_id(self, ids):
		url = 'http://dynamic.cloud.vip.xunlei.com/interface/task_pause?tid=%s&uid=%s&noCacheIE=%s' % (','.join(ids)+',', self.id, current_timestamp())
		assert self.urlopen(url).read() == 'pause_task_resp()'

	def pause_task_by_id(self, id):
		self.pause_tasks_by_id([id])

	def pause_task(self, task):
		self.pause_task_by_id(task['id'])

	def pause_tasks(self, tasks):
		self.pause_tasks_by_id(t['id'] for t in tasks)

	def restart_tasks(self, tasks):
		jsonp = 'jsonp%s' % current_timestamp()
		url = 'http://dynamic.cloud.vip.xunlei.com/interface/redownload?callback=%s' % jsonp
		form = []
		for task in tasks:
			assert task['type'] in ('ed2k', 'http', 'ftp', 'https', 'bt'), "'%s' is not tested" % task['type']
			data = {'id[]': task['id'],
					'cid[]': '', # XXX: should I set this?
					'url[]': task['original_url'],
					'download_status[]': task['status']}
			if task['type'] == 'ed2k':
				data['taskname[]'] = task['name'].encode('utf-8') # XXX: shouldn't I set this for other task types?
			form.append(urlencode(data))
		form.append(urlencode({'type':1}))
		data = '&'.join(form)
		response = self.urlopen(url, data=data).read()
		assert_response(response, jsonp)

	def rename_task(self, task, new_name):
		assert type(new_name) == unicode
		url = 'http://dynamic.cloud.vip.xunlei.com/interface/rename'
		taskid = task['id']
		bt = '1' if task['type'] == 'bt' else '0'
		url = url+'?'+urlencode({'taskid':taskid, 'bt':bt, 'filename':new_name.encode('utf-8')})
		response = self.urlopen(url).read()
		assert '"result":0' in response, response

	def restart_task(self, task):
		self.restart_tasks([task])

	def get_task_by_id(self, id):
		tasks = self.read_all_tasks(0)
		for x in tasks:
			if x['id'] == id:
				return x
		raise Exception('Not task found for id '+id)


def current_timestamp():
	return int(time.time()*1000)

def current_random():
	from random import randint
	return '%s%06d.%s' % (current_timestamp(), randint(0, 999999), randint(100000000, 9999999999))

def parse_task(html):
	inputs = re.findall(r'<input[^<>]+/>', html)
	def parse_attrs(html):
		return dict((k, v1 or v2) for k, v1, v2 in re.findall(r'''\b(\w+)=(?:'([^']*)'|"([^"]*)")''', html))
	info = dict((x['id'], unescape_html(x['value'])) for x in map(parse_attrs, inputs))
	mini_info = {}
	mini_map = {}
	#mini_info = dict((re.sub(r'\d+$', '', k), info[k]) for k in info)
	for k in info:
		mini_key = re.sub(r'\d+$', '', k)
		mini_info[mini_key] = info[k]
		mini_map[mini_key] = k
	taskid = mini_map['durl'][4:]
	url = mini_info['f_url']
	task_type = re.match(r'[^:]+', url).group()
	task = {'id': taskid,
			'type': task_type,
			'name': mini_info['durl'],
			'status': int(mini_info['d_status']),
			'status_text': {'0':'waiting', '1':'downloading', '2':'completed', '3':'failed', '5':'pending'}[mini_info['d_status']],
			'size': int(mini_info['ysfilesize']),
			'original_url': mini_info['f_url'],
			'xunlei_url': mini_info['dl_url'],
			'bt_hash': mini_info['dcid'],
			'dcid': mini_info['dcid'],
			'gcid': parse_gcid(mini_info['dl_url']),
			}

	m = re.search(r'<em class="loadnum"[^<>]*>([^<>]*)</em>', html)
	task['progress'] = m and m.group(1) or ''
	m = re.search(r'<em [^<>]*id="speed\d+">([^<>]*)</em>', html)
	task['speed'] = m and m.group(1).replace('&nbsp;', '') or ''
	m = re.search(r'<span class="c_addtime">([^<>]*)</span>', html)
	task['date'] = m and m.group(1) or ''

	return task

def parse_tasks(html):
	rwbox = re.search(r'<div class="rwbox".*<!--rwbox-->', html, re.S).group()
	rw_lists = re.findall(r'<div class="rw_list".*?<!-- rw_list -->', rwbox, re.S)
	return map(parse_task, rw_lists)

def parse_bt_list(js):
	result = json.loads(re.match(r'^fill_bt_list\((.+)\)\s*$', js).group(1))['Result']
	files = []
	for record in result['Record']:
		files.append({
			'id': int(record['taskid']),
			'index': record['id'],
			'type': 'bt',
			'name': record['title'], # TODO: support folder
			'status': int(record['download_status']),
			'status_text': {'0':'waiting', '1':'downloading', '2':'completed', '3':'failed'}[record['download_status']],
			'size': int(record['filesize']),
			'original_url': record['url'],
			'xunlei_url': record['downurl'],
			'dcid': record['cid'],
			'gcid': parse_gcid(record['downurl']),
			'speed': '',
			'progress': '%s%%' % record['percent'],
			'date': '',
			})
	return files

def parse_gcid(url):
	if not url:
		return
	m = re.search(r'&g=([A-F0-9]{40})&', url)
	if not m:
		return
	return m.group(1)

def urlencode(x):
	def unif8(u):
		if type(u) == unicode:
			u = u.encode('utf-8')
		return u
	return urllib.urlencode([(unif8(k), unif8(v)) for k, v in x.items()])

def encode_multipart_formdata(fields, files):
	#http://code.activestate.com/recipes/146306/
	"""
	fields is a sequence of (name, value) elements for regular form fields.
	files is a sequence of (name, filename, value) elements for data to be uploaded as files
	Return (content_type, body) ready for httplib.HTTP instance
	"""
	BOUNDARY = '----------ThIs_Is_tHe_bouNdaRY_$'
	CRLF = '\r\n'
	L = []
	for (key, value) in fields:
		L.append('--' + BOUNDARY)
		L.append('Content-Disposition: form-data; name="%s"' % key)
		L.append('')
		L.append(value)
	for (key, filename, value) in files:
		L.append('--' + BOUNDARY)
		L.append('Content-Disposition: form-data; name="%s"; filename="%s"' % (key, filename))
		L.append('Content-Type: %s' % get_content_type(filename))
		L.append('')
		L.append(value)
	L.append('--' + BOUNDARY + '--')
	L.append('')
	body = CRLF.join(L)
	content_type = 'multipart/form-data; boundary=%s' % BOUNDARY
	return content_type, body

def get_content_type(filename):
	import mimetypes
	return mimetypes.guess_type(filename)[0] or 'application/octet-stream'

def assert_default_page(response, id):
	#assert response == "<script>top.location='http://dynamic.cloud.vip.xunlei.com/user_task?userid=%s&st=0'</script>" % id
	assert re.match(r"^<script>top\.location='http://dynamic\.cloud\.vip\.xunlei\.com/user_task\?userid=%s&st=0(&cache=\d+)?'</script>$" % id, response), response

def remove_bom(response):
	if response.startswith('\xef\xbb\xbf'):
		response = response[3:]
	return response

def assert_response(response, jsonp):
	response = remove_bom(response)
	assert response == '%s(1)' % jsonp, repr(response)

def parse_url_protocol(url):
	m = re.match(r'([^:]+)://', url)
	if m:
		return m.group(1)
	elif url.startswith('magnet:'):
		return 'magnet'
	else:
		return url

def unescape_html(html):
	import xml.sax.saxutils
	return xml.sax.saxutils.unescape(html)

def md5(s):
	import hashlib
	return hashlib.md5(s).hexdigest().lower()

def encypt_password(password):
	if not re.match(r'^[0-9a-f]{32}$', password):
		password = md5(md5(password))
	return password

def ungzip(s):
	from StringIO import StringIO
	import gzip
	buffer = StringIO(s)
	f = gzip.GzipFile(fileobj=buffer)
	return f.read()

def undeflate(s):
	import zlib
	return zlib.decompress(s, -zlib.MAX_WBITS)


