#!/usr/bin/python
#coding=utf-8

from feedback import Feedback
import urllib2
import urllib
import json
import sys, os.path

AK              = '61d9c2b7e886b8f2e5bad831917b1c8d'
CITY            = '北京'
API_URL_BASE    = 'http://api.map.baidu.com/place'
MAP_URL_BASE    = 'http://map.baidu.com'


def init_env():
    global CITY, AK
    if os.path.exists('city.txt'):
        CITY = file('city.txt', 'r').read().strip('\r\n \t')

    if os.path.exists('akey.txt'):
        AK = file('akey.txt', 'r').read().strip('\r\n \t')

def main(args):
    global CITY, AK, API_URL_BASE, MAP_URL_BASE
    init_env()
    
    region = urllib.quote(CITY)

    if len(args) == 2:
        query = urllib.quote(args[1])
        # query = urllib.quote('天安门')

        result = json.load(urllib2.urlopen('%s/v2/search?&q=%s&region=%s&output=json&ak=%s' % (API_URL_BASE, query, region, AK)))
        feeds = Feedback()

        if result['status'] == 0:
            for i in result['results']:
                name    = i.get('name', '搜索不到结果')
                address = i.get('address', '')

                if urllib.quote('到') in query or urllib.quote('去') in query:
                    map_url = '%s/search?query=%s&region=%s&referer=alfredapp&output=html' % (API_URL_BASE, query, region)
                else:
                    map_url = '%s/search?query=%s&region=%s&referer=alfredapp&output=html' % (API_URL_BASE, name, region)
                
                feeds.add_item(title=name, subtitle=address, valid='YES', arg=map_url, icon='icon.png')
        else:
            feeds.add_item(title='内容未找到', subtitle='输入内容有误', valid='no', arg=MAP_URL_BASE, icon='icon.png')

        print(feeds)
    return

if __name__ == '__main__':
    main(sys.argv)