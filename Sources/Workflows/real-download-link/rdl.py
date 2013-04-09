#!/usr/bin/env python
# -*- coding: utf-8 -*-
#! 强制默认编码为utf-8
import sys
reload(sys)
sys.setdefaultencoding('utf8')

import os, base64, urllib
from urlparse import urlparse

import alfred

from pprint import pprint

DLTypeDesc = {
    'ed2k'      : 'eMule',
    'emule'     : 'eMule',
    'qqdl'      : 'QQ旋风',
    'thunder'   : '迅雷',
    'flashget'  : '快车',
    'magnet'    : '磁力链'
}

class RealDownloadLink(object):
    def __init__(self):
        pass

    def run(self):
        url = sys.argv[1]
        res = self.parse(url)
        feedback = alfred.Feedback()
        feedback.addItem(
            title       = res['real'],
            subtitle    = '{} {} {}'.format(self.getTypeDesc(res['type']), res['filename'], res['filesize']),
            arg         = res['real']
            )
        feedback.output()

    def die(self, **kwargs):
        feedback = alfred.Feedback()
        feedback.addItem(**kwargs)
        feedback.output()
        sys.exit(1)

    def getTypeDesc(self, t):
        if t in DLTypeDesc:
            return DLTypeDesc[t]
        elif t in ['http', 'https', 'ftp', 'ftps', 'sftp']:
            return t.upper()
        return 'UNKNOWN'

    def buildResult(self, url, urltype='UNKNOWN', real=None, filename=None, filesize=None):
        return {
            'type'      : urltype,
            'org'       : url,
            'real'      : real if real else url,
            'filename'  : urllib.unquote(filename) if filename else '',
            'filesize'  : filesize if filesize else ''
        }

    def parse(self, url):
        parse_map = {
            'ed2k'      : lambda: self.parseEd2k(url),
            'thunder'   : lambda: self.parseThunder(url),
            'flashget'  : lambda: self.parseFlashget(url),
            'qqdl'      : lambda: self.parseQQdl(url)
        }
        scheme = urlparse(url).scheme
        if scheme in parse_map.keys():
            return parse_map[scheme]()
        elif scheme in ['http', 'https', 'ftp', 'ftps', 'sftp']:
            return self.parseNormal(url)
        elif scheme in ['magnet']:
            return self.buildResult(url, scheme)
        return self.buildResult(url)

    def parseNormal(self, url):
        uri = urlparse(url)
        filename = os.path.basename(uri.path)
        return self.buildResult(url, uri.scheme, url, filename)

    def parseEd2k(self, url):
        name = ''
        size = ''
        try:
            parts = url.split('|')
            name = parts[2]
            size  = self.humanReadable(parts[3])
        except Exception, e:
            pass
        return self.buildResult(url, 'emule', url, name, size)

    def parseThunder(self, url):
        # 格式: thunder://CODEPART
        # CODEPART = 'AA真实地址ZZ'的base64编码
        uri = urlparse(url)
        try:
            real = uri.netloc
            # base64解码
            real = base64.b64decode(real)
            #去除前后的AA ZZ
            real = real[2:-2]
            res = self.parse(real)
            res['type'] = 'thunder'
            return res
        except Exception, e:
            self.die(title=url, subtitle=self.getTypeDesc('thunder'))  

    def parseFlashget(self, url):
        # 格式: flashget://CODEPART&HASHCODE
        # CODEPART = '[FLASHGET]真实地址[FLASHGET]'的base64编码
        # HASHCODE 无用 可有可无
        uri = urlparse(url)
        try:
            real = uri.netloc
            # 去除HASHCODE
            if real.rfind('&') >= 0:
                real = real[0:real.rfind('&')]
            # base64解码
            real = base64.b64decode(real)
            # 去除 [FLASHGET] [FLASHGET]
            real = real[10:-10]
            res = self.parse(real)
            res['type'] = 'flashget'
            return res
        except Exception, e:
            self.die(title=url, subtitle=self.getTypeDesc('flashget'))
        
    def parseQQdl(self, url):
        # 格式: qqdl://CODEPART
        # CODEPART = 真实地址的base64编码
        uri = urlparse(url)
        try:
            # base64解码
            real = base64.b64decode(uri.netloc)
            res = self.parse(real)
            res['type'] = 'qqdl'
            return res
        except Exception, e:
            self.die(title=url, subtitle=self.getTypeDesc('qqdl'))

    def humanReadable(self, byte):
        if isinstance(byte, (str, unicode)):
            byte = int(byte) if byte.isdigit() else 0
        size = byte / 1024.0
        unit = 'KB'
        if size > 1024:
            size = size / 1024.0
            unit = 'MB'
        if size > 1024:
            size = size / 1024.0
            unit = 'GB'
        return '{:.2f}{}'.format(size, unit)

if __name__ == '__main__':
    RealDownloadLink().run()