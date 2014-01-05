
# coding: utf-8
# 获取FIS配置项，并用来在alfred展示

import os
import re
import sys
import time
import urllib
import urllib2

# 序列化
import pickle


class DocParser():
    '''
    分析API页面，得到每一个配置项
    '''
    doc_string = ''
    def __init__(self, s):
        self.doc_string = s

    def parse(self):
        docs = {}
        items = self._items()
        if len(items) > 0:
            for item in items:
                title = self._title(item[0])
                if not title:
                    continue
                detail = self._detail(item[1])
                docs[title[1]] = {
                    'link': title[0],
                    'options': detail
                }
        return docs

    def _items(self):
        res = re.findall(r'<h3>((?:(?!</h3>)[\s\S])+)</h3>\s+<ul>((?:(?!</ul>)[\s\S])+)</ul>', self.doc_string)
        return res


    def _title(self, str):
        res = re.findall(r'<a[\s\S]*?href\s*=\s*(\'(?:[^\\\'\n\r\f]|\\[\s\S])*\'|"(?:[^\\"\r\n\f]|\\[\s\S])*"|\S+)[\s\S]*</a>([\s\S]+)', str)
        if res:
            return res[0]
        return False

    def _detail(self, str):
        ret = []
        res = re.findall('<li>((?:(?!<\/li>)[\s\S])+)</li>', str)
        if res:
            for row in res:
                s = self._del_html_tag(row)
                ret.append(s.strip())
        return ret

    def _del_html_tag(self, str):
        return re.sub(r'<\w+[^>]*>([\s\S]*?)</\w+[^>]*>', r'\1', str)

class FIS(object):
    '''
    获取FIS所有的配置型，并返回为alfred支持的xml格式。
    '''
    docs = {}
    # url of the doc
    doc_url = ''

    cache_file = ''

    CACHE_MAX_TIME = 108000

    def __init__(self, config = {}):
        if 'url' in config:
            self.doc_url = config['url']
        else:
            self.doc_url = 'https://github.com/fis-dev/fis/wiki/配置API'
        self.cache_file = os.environ['HOME'] + '/.fis/cache/alf.cache'
        docs = self.get_cache()
        if not docs:
            docs = self.fetch_url()
        self.docs = docs

    def set_cache(self, docs):
        dirname = os.path.dirname(self.cache_file)
        if not os.path.isdir(dirname):
            os.makedirs(dirname)
        dump_file = open(self.cache_file, 'w')
        pickle.dump({'last_modify': time.time(), 'docs': docs}, dump_file)
        dump_file.close()

    def get_cache(self):
        if not os.path.isfile(self.cache_file):
            return False
        dump_file = open(self.cache_file, 'r')
        data = pickle.load(dump_file)
        dump_file.close()

        if (time.time() - data['last_modify'] > self.CACHE_MAX_TIME):
            return False

        return data['docs']

    def update(self):
        self.fetch_url()

    def fetch_url(self):
        reqest = urllib2.urlopen(urllib.quote_plus(self.doc_url, '/:'))
        if reqest.getcode() != 200:
            raise Exception('Cant\'t connect https://github.com')
        doc = reqest.read()
        parser = DocParser(doc)
        res = parser.parse()
        self.set_cache(res)
        return res

    def list(self, query):
        if self.docs:
            xml = '<items>'
            for k in self.docs:
                # search
                if not self.string_match(k, query):
                    continue
                desc =  self.docs[k]['options'][0]
                link = self.docs[k]['link']
                xml += '<item uid="'+k+'" arg='+link+'>'
                xml += '<title>'+k+'</title>'
                xml += '<subtitle><![CDATA['+desc+']]></subtitle>'
                xml += '<icon>fis.png</icon>'
                xml += '</item>'
            xml += '</items>'
        return xml

    def string_match(self, string, query):
        reg = re.compile(query)
        r = reg.search(string)
        ret = False
        if r:
            ret = True
        return ret


if __name__ == '__main__':

    if len(sys.argv) < 2:
        sys.exit(1)

    q = sys.argv[1]
    try:
        fis = FIS()
        if q == 'update':
            fis.update()
            print 'update success.'
        else:
            print fis.list(q)
    except:
        if q == 'update':
            print 'There is something with wrong.'
        else:
            print '<items><item><title>There is something with wrong.</title><icon>fis.png</icon></item></items>'
