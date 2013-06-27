import json
import os
import re
import time
import urllib2
import alfred

(action, query) = alfred.args() # proper decoding and unescaping of command line arguments

APPS_FILE_PATH = 'apps.json'


def should_update():
	# age = (24 * 60 * 60)
	age = 60 * 60 * 24
	file = APPS_FILE_PATH
	try :
		date_modified = os.stat(file).st_mtime
		diff = time.time() - date_modified
		return diff > age
	except:
		return True


def get_apps_from_github(request_url='https://api.github.com/repos/phinze/homebrew-cask/contents/Casks', request_data=None):
	print 'getting data from github'
	request_headers = {'Content-Type': 'application/json; charset=UTF-8', 'X-Accept': 'application/json'}
	request = urllib2.Request(request_url, request_data, request_headers)
	response = urllib2.urlopen(request)
	data = json.load(response)
	obj = {}
	for app in data:
		obj[app["name"][:-3]] = app["html_url"].replace('github.com','raw.github.com').replace('/blob','')


	with open('apps.json', 'w') as myFile:
		myFile.write(json.dumps(obj,indent=4,sort_keys=True))
	return data


def get_apps():
	if should_update() == True :
		apps = get_apps_from_github()
	else:
		apps = json.loads(open('apps.json').read())
	
	return apps


apps_list = get_apps()

matched_apps = []
reObj = re.compile(query,re.IGNORECASE)
for key in apps_list.keys():
	if(reObj.search(key)):
		item = alfred.Item(
			attributes={'uid': alfred.uid(0), 'arg': apps_list[key]},
			title=" ".join(str(key).capitalize().split('-')),
			icon='icon.png',
			subtitle=u'Install %s on your mac' % " ".join(str(key).capitalize().split('-'))
		)

		matched_apps.append(item)


xml = alfred.xml(matched_apps) # compiles the XML answer
alfred.write(xml) # writes the XML back to Alfred


