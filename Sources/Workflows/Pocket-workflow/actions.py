import json
import os
import re
import urllib
import alfred
import pocket

(action, query) = alfred.args() # proper decoding and unescaping of command line arguments


def login():
	code = pocket.getRequestCode()
	with open('code.json', 'w') as myFile:
		myFile.write(json.dumps(code))

	results = [alfred.Item(
		attributes={'uid': alfred.uid(0), 'arg': code["code"]},
		title='Login!',
		icon='icon.png',
		subtitle=u'Login with Pocket.com (you will be taken to pocket.com)'
	)] # a single Alfred result
	xml = alfred.xml(results) # compiles the XML answer
	alfred.write(xml) # writes the XML back to Alfred

def post():
	obj = applescript(query)
	pocket.post(obj)


def applescript(argument):
	if argument == "isChrome":
		return os.popen("""osascript -e 'tell app "System Events" to count processes whose name is "Google Chrome"' """).read().rstrip()
	if argument == "isSafari":
		return os.popen("""osascript -e 'tell app "System Events" to count processes whose name is "Safari"' """).read().rstrip()
	if argument == "chrome":
		obj = {}
		obj["url"] =  os.popen(""" osascript -e 'tell application "Google Chrome" to return URL of active tab of front window' """).readline()
		obj["title"] =  os.popen(""" osascript -e 'tell application "Google Chrome" to return title of active tab of front window' """).readline()
		return obj
	if argument == "safari":
		obj = {}
		obj["url"] =  os.popen(""" osascript -e 'tell application "Safari" to return URL of front document' """).readline()
		obj["title"] =  os.popen(""" osascript -e 'tell application "Safari" to return name of front document' """).readline()
		return obj
	if argument == 'isClipboard':
		clip = os.popen(""" osascript -e "get the clipboard" """).readline()
		try:
			url = re.search("(?P<url>https?://[^\s]+)", clip).group("url")
		except:
			url = ""
		return bool(url)
	if argument == 'clip':
		obj = {}
		clip = os.popen(""" osascript -e "get the clipboard" """).readline()
		try:
			obj["url"] = re.search("(?P<url>https?://[^\s]+)", clip).group("url")
		except:
			obj["url"] = ""
		return obj


def get_actions():
	arr = []
	isChrome = bool(int(applescript("isChrome")))
	isSafari = bool(int(applescript("isSafari")))
	isClipboard = applescript("isClipboard")

	if isChrome:
		chrome_url = applescript("chrome")
		arr.append(alfred.Item(
			attributes={'uid': alfred.uid(0), 'arg': "chrome"},
			title='Pocket - save url from Chrome',
			icon='icon.png',
			subtitle= chrome_url["title"].decode('utf8')
		))
	if isSafari:
		s_url = applescript("safari")
		arr.append(alfred.Item(
			attributes={'uid': alfred.uid(0), 'arg': "safari"},
			title='Pocket - save url from Safari',
			icon='icon.png',
			subtitle=s_url["title"].decode('utf8')
		))
	if isClipboard:
		c_url = applescript("clip")
		arr.append(alfred.Item(
				attributes={'uid': alfred.uid(0), 'arg': "clip"},
				title='Pocket - save url from Clipboard',
				icon='icon.png',
				subtitle=c_url["url"].decode('utf8')
			))
	xml = alfred.xml(arr)
	alfred.write(xml)

if action == 'login':
	login()
elif action == 'post':
	post()
elif action == 'get_actions':
	get_actions()