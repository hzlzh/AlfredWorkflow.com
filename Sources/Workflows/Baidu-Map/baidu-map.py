#coding=utf-8

from feedback import Feedback
import urllib2
import urllib
import json
import sys, os.path

AK = 'D08b57468c1cbc0ab18ed13be96058f7'
CITY = '北京'

if os.path.exists('city.txt'):
    CITY = file('city.txt', 'r').read().strip('\r\n \t')

region = urllib.quote(CITY)

if len(sys.argv) == 2:
    query = urllib.quote(sys.argv[1])
    # query = urllib.quote('天安门')

    result = json.load(urllib2.urlopen('http://api.map.baidu.com/place/v2/search?&q=%s&region=%s&output=json&ak=%s' % (query, region, AK)))

    feeds = Feedback()

    if result['status'] == 0:
        for i in result['results']:
            map_url = 'http://api.map.baidu.com/place/search?query=%s&location=%s,%s&radius=1000&region=%s&referer=alfredapp&output=html' % (query, i['location']['lat'], i['location']['lng'], region)
            feeds.add_item(title=i['name'], subtitle=i['address'], valid='YES', arg=map_url, icon='icon.png')

        print feeds