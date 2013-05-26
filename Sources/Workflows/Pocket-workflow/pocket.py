import json
import logging
import urllib2

logger = logging.getLogger('alfred.fundbox')
hdlr = logging.FileHandler('/var/tmp/alfred.fundbox.log')
formatter = logging.Formatter('%(asctime)s %(levelname)s %(message)s')
hdlr.setFormatter(formatter)
logger.addHandler(hdlr)
logger.setLevel(logging.INFO)

CONSUMER_KEY = '12483-e2a74088174a17f2872c4d82'
REDIRECT_URI = 'http://alexw.me'
POCKET_API_URL = 'https://getpocket.com/v3/oauth/'


def getRequestCode():
	logger.info("Trying to get request code")
	req_data = json.dumps({
		"consumer_key": CONSUMER_KEY, "redirect_uri": REDIRECT_URI
	})
	resp_data = makeRequest(req_data, POCKET_API_URL + 'request/')
	logger.info("got response data : " + str(resp_data))
	return resp_data

def getAuthToken():
	try:
		code = json.loads(open('code.json').read())["code"]
	except:
		print "Please try to login first with pocket_login"
	logger.info("request code is" + code)
	req_data = json.dumps({
				"consumer_key": CONSUMER_KEY, "code": code
			})
	logger.info("Trying to get auth token")
	try:
		resp_data = makeRequest(req_data, POCKET_API_URL + 'authorize/')
		logger.info('Token received! :'+ resp_data["access_token"])
		with open('auth.json', 'w') as myFile:
			myFile.write(json.dumps(resp_data))
		print "Logged in as "+ resp_data["username"]
	except Exception:
		logger.error(Exception.message)
		print "Could not login - something went wrong"

def post(obj):
	try:
		token = json.loads(open('auth.json').read())["access_token"]
	except:
		print "Please try to login first with pocket_login"

	req_data = {
		"consumer_key": CONSUMER_KEY,
		"access_token": token
	}
	req_data.update(obj)

	resp = makeRequest(json.dumps(req_data),'https://getpocket.com/v3/add/')
	if resp["status"] == 1:
		print "Succesfully posted to pocket"

def makeRequest(request_data, request_url):
	request_headers = {'Content-Type': 'application/json; charset=UTF-8', 'X-Accept': 'application/json'}
	request = urllib2.Request(request_url, request_data, request_headers)
	response = urllib2.urlopen(request)
	data = json.load(response)
	return data
