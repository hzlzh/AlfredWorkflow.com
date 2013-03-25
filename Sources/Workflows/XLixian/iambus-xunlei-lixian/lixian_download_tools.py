
from lixian_config import *
import subprocess
import urllib2
import os.path

def urllib2_download(client, download_url, filename, resuming=False):
	'''In the case you don't even have wget...'''
	assert not resuming
	print 'Downloading', download_url, 'to', filename, '...'
	request = urllib2.Request(download_url, headers={'Cookie': 'gdriveid='+client.get_gdriveid()})
	response = urllib2.urlopen(request)
	import shutil
	with open(filename, 'wb') as output:
		shutil.copyfileobj(response, output)

def asyn_download(client, download_url, filename, resuming=False):
	import lixian_download_asyn
	lixian_download_asyn.download(download_url, filename, headers={'Cookie': 'gdriveid='+str(client.get_gdriveid())}, resuming=resuming)

def wget_download(client, download_url, filename, resuming=False):
	gdriveid = str(client.get_gdriveid())
	wget_opts = ['wget', '--header=Cookie: gdriveid='+gdriveid, download_url, '-O', filename]
	if resuming:
		wget_opts.append('-c')
	wget_opts.extend(get_config('wget-opts', '').split())
	exit_code = subprocess.call(wget_opts)
	if exit_code != 0:
		raise Exception('wget exited abnormaly')

def curl_download(client, download_url, filename, resuming=False):
	gdriveid = str(client.get_gdriveid())
	curl_opts = ['curl', '-L', download_url, '--cookie', 'gdriveid='+gdriveid, '--output', filename]
	if resuming:
		curl_opts += ['--continue-at', '-']
	curl_opts.extend(get_config('curl-opts', '').split())
	exit_code = subprocess.call(curl_opts)
	if exit_code != 0:
		raise Exception('curl exited abnormaly')

def aria2_download(client, download_url, path, resuming=False):
	gdriveid = str(client.get_gdriveid())
	dir = os.path.dirname(path)
	filename = os.path.basename(path)
	aria2_opts = ['aria2c', '--header=Cookie: gdriveid='+gdriveid, download_url, '--out', filename, '--file-allocation=none']
	if dir:
		aria2_opts.extend(('--dir', dir))
	if resuming:
		aria2_opts.append('-c')
	aria2_opts.extend(get_config('aria2-opts', '').split())
	exit_code = subprocess.call(aria2_opts)
	if exit_code != 0:
		raise Exception('aria2c exited abnormaly')

def axel_download(client, download_url, path, resuming=False):
	gdriveid = str(client.get_gdriveid())
	axel_opts = ['axel', '--header=Cookie: gdriveid='+gdriveid, download_url, '--output', path]
	axel_opts.extend(get_config('axel-opts', '').split())
	exit_code = subprocess.call(axel_opts)
	if exit_code != 0:
		raise Exception('axel exited abnormaly')

# TODO: support axel, ProZilla


def get_tool(name):
	return {'wget':wget_download, 'curl': curl_download, 'aria2':aria2_download, 'aria2c':aria2_download, 'axel':axel_download, 'asyn':asyn_download, 'urllib2':urllib2_download}[name]


