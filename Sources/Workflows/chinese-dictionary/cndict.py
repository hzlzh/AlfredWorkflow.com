#!/usr/bin/env python
# -*- coding: utf-8 -*-
#! 强制默认编码为utf-8
import sys
reload(sys)
sys.setdefaultencoding('utf8') 

import urllib, urllib2, json, time
from pprint import pprint
from pdb import set_trace

from alfred.feedback import Feedback 

services = {
    'qq'    : {
        'api'   : 'http://dict.qq.com/dict',
        'web'   : 'http://dict.qq.com/dict?f=cloudmore&q={}',
        'icon'  : 'icon.png',
    },
    'iciba' : {
        'api'   : 'http://dict-co.iciba.com/api/dictionary.php',
        'web'   : 'http://www.iciba.com/{}',
        'icon'  : 'iciba-icon.png'
    }
}

class Dict(object):
    def __init__(self):
        self.service = services['qq']
        self.query_word =''
        self.feedback = Feedback()

    def fetch(self, word):
        return {}

    def parse(self, data):
        pass

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

# QQ 词典
class QQDict(Dict):
    def __init__(self):
        super(QQDict, self).__init__()
        self.service = services['qq']

        # 从字典中安全的取出值
        self.save_get_dict_value = lambda d, k: d[k] if d.has_key(k) else ''

    def fetch(self, word):
        data = {'q': word}
        data = urllib.urlencode(data)
        url = '{}?{}'.format(self.service['api'], data)
        try:
            requst = urllib2.urlopen(url)
            res = json.load(requst)
        except:
            return {}
        return res

    def parse(self, data):
        if not data or not isinstance(data, dict):
            return
        if not data.has_key('lang'):
            return
        lang = data['lang']
        if lang == 'eng':
            self.parseENG(data)
        elif lang == 'ch':
            self.parseCH(data)

    # 英译中
    def parseENG(self, data):
        if not data.has_key('local') or not data['local'][0]:
            return
        local = data['local'][0]
        try:
            # 发音 语素
            word = local['word']
            mors = []
            if local.has_key('mor') and local['mor']:
                for mor in local['mor']:
                    c = self.save_get_dict_value(mor, 'c')
                    m = self.save_get_dict_value(mor, 'm')
                    if not c or not m:
                        continue
                    mors.append('{}: {}'.format(c, m))
            title = self.getWordAndPho(local)
            subtitle = ' '.join(mors)
            self.addItem(title = title, subtitle = subtitle, arg = local['word'])
            # 解释
            if local.has_key('des') and local['des']:
                for des in local['des']:
                    title = self.getDes(des)
                    if not title:
                        continue
                    self.addItem(title = title, arg = word)
        except Exception, e:
            raise e

    # 中译英
    def parseCH(self, data):
        if not data.has_key('local') or not data['local'][0]:
            return
        try:
            local = data['local'][0]
            word = local['word']
            # 发音 英文翻译
            title = self.getWordAndPho(local)
            subtitle = '; '.join(local['des']) if local.has_key('des') else ''
            self.addItem(title = title, subtitle = subtitle, arg = word)
            # 英文翻译的具体解释
            if local.has_key('des2'):
                for des in local['des2']:
                    title = self.getWordAndPho(des)
                    subtitle = ''
                    if des.has_key('des'):
                        sub_deses = []
                        for sub_des in des['des']:
                            sub_des_str = self.getDes(sub_des)
                            if sub_des_str:
                                sub_deses.append(sub_des_str)
                        subtitle = '; '.join(sub_deses)   
                    self.addItem(title = title, subtitle = subtitle, autocomplete = des['word'])
                    
        except Exception, e:
            raise e

    def getWordAndPho(self, data):
        word = data['word']
        pho = ''
        if data.has_key('pho'):
            phos = []
            for sub_pho in data['pho']:
                if not sub_pho:
                    continue
                phos.append('[{}]'.format(sub_pho))
            pho = ' '.join(phos)
        return '{} {}'.format(word, pho)

    def getDes(self, data):
        p = self.save_get_dict_value(data, 'p')
        d = self.save_get_dict_value(data, 'd')
        if not p and not d:
            return ''
        return '{} {}'.format(p, d).strip()

class iCIBADict(Dict):
    pass

if __name__ == '__main__':
    d = QQDict()
    d.query(sys.argv[1])
    d.output()