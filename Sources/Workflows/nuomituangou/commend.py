# -*- coding: UTF-8 -*-

import alfred
import urllib, urllib2
import json
import sys


def OnlyCharNum(s,oth=''):
    s = s.lower();
    fomart = 'abcdefghijklmnopqrstuvwxyz013456789'
    for c in s:
        if not c in fomart:
            s = s.replace(c,'');
    return s;


def main():
    reload(sys)                         # reload unicode decoder
    sys.setdefaultencoding('utf-8')     # use utf-8
    (param, word) = alfred.args()
    cityCode = '100010000' # Beijing

    if word.isspace():
        url = "http://m.nuomi.com/client/gethotkeyword?cityid=%s&limit=20&client=ios&version=3.2.0" % (cityCode)
    else:
        word = OnlyCharNum(word)
        url = "http://m.nuomi.com/client/searchsuggest?k=%s&cityid=%s" % (word, cityCode)
    req = urllib2.Request(url)
    response = urllib2.urlopen(req)
    data = json.loads(response.read())
    results = []
    if word.isspace():
        if len(data['keywords']) == 0:
            results.append(alfred.Item({'uid': 0, 'arg': word}, word, '', 'icon.png'))
        else:
            for i in range(0, len(data['keywords'])):
                results.append(alfred.Item({'uid': i, 'arg': data['keywords'][i]['keyword']}, data['keywords'][i]['keyword'], '', 'icon.png'))
    else:
        if len(data['data']) == 0:
            results.append(alfred.Item({'uid': 0, 'arg': word}, word, '', 'icon.png'))
        else:
            for i in range(0, len(data['data'])):
                results.append(alfred.Item({'uid': i, 'arg': data['data'][i]['t']}, data['data'][i]['t'], '', 'icon.png'))
    xml = alfred.xml(results) # compiles the XML answer
    alfred.write(xml)

if __name__ == '__main__':
    main()