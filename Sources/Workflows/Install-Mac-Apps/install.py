from shutil import copyfileobj
import shutil
from subprocess import call
import urllib
import urllib2
import sys
import zipfile
import time
import notify


__author__ = 'altryne'


import os,alfred

(action, query) = alfred.args() # proper decoding and unescaping of command line arguments

DOWNLOADS_FOLDER = os.path.join(os.path.expanduser('~'),'Downloads')
APP_FOLDER = os.path.join(os.path.expanduser('~'),'Applications')

os.chdir(DOWNLOADS_FOLDER)

def get_raw_file(request_data=None):
	request_url=query
	request_headers = {'Content-Type': 'application/json; charset=UTF-8', 'X-Accept': 'application/json'}
	request = urllib2.Request(request_url, request_data, request_headers)
	response = urllib2.urlopen(request)
	return response.read().splitlines()

info = get_raw_file()[1:][:-1]
obj = {}
for line in info:
	key,val = line.strip().partition(' ')[::2]
	obj[key] = val

print obj

def extract_files(dirname):
	for root, dirs, files in os.walk(dirname, True, None):
		remove = [".background",".Trashes",".DS_Store","Applications"]

		for idir in dirs:
			if dir in remove:
				continue
			dname, ext = os.path.splitext(idir)
			if (ext == '.app'):
				path = os.path.join(root, idir)
				try:
					shutil.copytree(path, os.path.join(APP_FOLDER, idir), symlinks=True)
					notify.notify("Success!", "%s was installed!" % dname, "Enjoy!", sound=True, delay=5)
				except Exception as e:
					print e
					notify.notify("Oooops", "Something went wrong", "%s" % e, sound=True,delay=5)
				return



		for lfile in files:
			if lfile in remove:
				continue
			fname, ext = os.path.splitext(lfile)
			if not fname.startswith('.') and ext == '.dmg':
				print 'DMG FOUND!! install dmg!'
				mount_and_install(os.path.join('tmp', lfile))
				break
			elif ext == '.pkg':
				print 'PKG file found. OMG OGM'
				break
		else:
			continue



def mount_and_install(filename):
	if not os.path.exists('tmp'):
			os.makedirs('tmp')
	print 'tryint to mount %s' % filename
	try:
		shell_command = 'hdiutil attach -mountpoint "%s" %s' % ('tmp/my-temp-mount',os.path.abspath(filename))
		print shell_command
		call(shell_command,shell=True)
		try:
			extract_files('tmp/my-temp-mount')
		finally:
			call('hdiutil detach "tmp/my-temp-mount"' ,shell=True)
	except Exception as e:
		print 'err!! : %s' % e
	pass

def unzip_and_install(filename):
	zfile = zipfile.ZipFile(filename)
	#change dir to downloads folder

	#create a temporary dir
	if not os.path.exists('tmp'):
		os.makedirs('tmp')

	zfile.extractall('tmp')

	extract_files('tmp')

	#cleaning up
	shutil.rmtree('tmp')

try:
	url = obj["url"][1:][:-1]
	name = obj["url"][1:][:-1].split('/')[-1]
	filename = os.path.join(DOWNLOADS_FOLDER,name)

	notify.notify("Downloading Started", "Downloading %s V. %s " % (name,obj["version"]), "To %s" % filename)
	previous = 0
	def prg(count, blockSize, totalSize):
		global previous
		percent = int(count * blockSize * 100 / totalSize)
		sys.stdout.write("\r" + url + "...%d%%" % percent)

		if percent != previous and (percent % 20) == 0:
			previous = percent
			notify.notify("Downloading %s" % filename, "Percentage : %s%%" % percent, "", sound=False)
		sys.stdout.flush()

	urllib.urlretrieve(url,filename,reporthook=prg)
	print "\n"

	#this is needed so lion won't collate notifications
	time.sleep(3)
	notify.notify("Downloading Finished", "Downloaded %s. " %filename, "Please wait while I extract and mount", sound=False)


	# try to unpack

	name,ext = os.path.splitext(filename)

	if (ext == '.zip') :
		print "zip file found, unzipping"
		unzip_and_install(filename)
	elif (ext == '.dmg'):
		print "dmg file found, mounting"
		mount_and_install(filename)
	else :
		print "can't handle this file"

	# cleanup remove downloaded file

	os.remove(filename)

except Exception as e:
	print 'oops',e
	notify.notify("Oops", "Something went wrong", e.message, sound=True)



