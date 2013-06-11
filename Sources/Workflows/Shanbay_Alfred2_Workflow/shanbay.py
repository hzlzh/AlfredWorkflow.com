#!/usr/bin/env python
# -*- coding: utf-8 -*-
#! 强制默认编码为utf-8
import sys
reload(sys)
sys.setdefaultencoding('utf8') 

import urllib, urllib2, json, time
from pprint import pprint
from pdb import set_trace
import requests
from lxml import html

from alfred.feedback import Feedback 

from config import service, addword, loginurl, username, pwd

# 扇贝词典
class ShanbayDict():
    def __init__(self):
        self.service = service
        self.query_word =''
        self.feedback = Feedback()

        # 从字典中安全的取出值
        self.save_get_dict_value = lambda d, k: d[k] if d.has_key(k) else ''

    def get_csrfmiddlewaretoken(self):
        page = requests.get(loginurl).text
        script = html.fromstring(page).xpath("(//input[@name='csrfmiddlewaretoken']/@value)[1]")[0]
        return script

    def login(self):

        csrftoken = self.get_csrfmiddlewaretoken()

        postdata = {}
        postdata['csrfmiddlewaretoken'] = csrftoken
        postdata['username'] = username
        postdata['password'] = pwd
        postdata['login'] = ''
        postdata['continue'] = 'home'
        postdata['u'] = 1
        postdata['next'] = '/review/new/'
        headers = {
                    'User-Agent':'Mozilla/5.0 (X11; Linux i686; rv:8.0) Gecko/20100101 Firefox/8.0',
                    'Host':'www.shanbay.com',
                    'Origin':'http://www.shanbay.com',
                    'Referer':'http://www.shanbay.com/accounts/login/',
                    'Cookie':'csrftoken='+csrftoken+';csrftoken='+csrftoken+';sessionid=f7df88e25d184e487df6ddc6a88caafb;',
                    'Accept':'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                    'Accept-Charset':'UTF-8,*;q=0.5',
                    'Accept-Encoding':'gzip,deflate,sdc',
                    'Accept-Language':'en-US,en;q=0.8,zh-CN;q=0.6,zh;q=0.4',
                    'Cache-Control':'max-age=0',
                    'Connection':'keep-alive',
                    'Content-Type':'application/x-www-form-urlencoded'
                  }

        #r = requests.post(url, data=json.dumps(postdata), headers=headers)
        r = requests.post(loginurl, data=postdata, headers=headers)
        #print r.status_code
        #print r.headers
        self.cookies = r.cookies
        return True if r.status_code == 200 else False


    def fetch(self, word):
        islogin = self.login()
        if islogin == False:
            print '登陆失败'
            return

        url = self.service+word

        try:
            r = requests.get(url, cookies = self.cookies)
            res = json.loads(r.text)
        except:
            return {}
        return res

    def parse(self, data):

        if(data['voc']):
            voc = data['voc']
            word = voc['content']

            # 发音
            pron = voc['pron']
            title = "%s [%s]" % (word, pron)
            subtitle = voc['definition']
            self.addItem(title = title, subtitle = subtitle, arg = word)
            # 解释
            if voc.has_key('en_definitions') and voc['en_definitions']:
                for type in voc['en_definitions']:
                    for line in voc['en_definitions'][type]:
                        title = type+', '+line
                        if not title:
                            continue
                        self.addItem(title = title, arg = word)
        else:
            self.addItem(title='no results')

    def query(self, word):
        if not word or not isinstance(word, (str, unicode)):
            return
        self.query_word = word
        self.parse( self.fetch(word) )

    def addItem(self, **kwargs):
        self.feedback.addItem(**kwargs)

    def output(self):
        if self.feedback.isEmpty():
            self.addItem(
                title       = self.query_word, 
                subtitle    = 'Sorry, no result.', 
                arg         = self.query_word )
        print(self.feedback.get(unescape = True))


if __name__ == '__main__':
    d = ShanbayDict()
    d.query(sys.argv[1])
    d.output()
