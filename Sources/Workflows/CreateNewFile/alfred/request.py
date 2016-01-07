# -*- coding: utf-8 -*-
from __future__ import absolute_import, division, unicode_literals
import os
import base64

from . import core

if core.PY2:
    from urllib import ContentTooShortError
    from urllib2 import HTTPError, URLError
    from urllib import urlencode
    from urllib2 import Request as urlRequest
    from urllib2 import build_opener
    from urllib2 import HTTPHandler, HTTPSHandler, HTTPCookieProcessor
    import Cookie
    from cookielib import CookieJar

if core.PY3:
    from urllib.error import ContentTooShortError, HTTPError, URLError
    from urllib.parse import urlencode
    from urllib.request import Request as urlRequest
    from urllib.request import build_opener
    from urllib.request import HTTPHandler, HTTPSHandler, HTTPCookieProcessor
    from http import cookies as Cookie
    from http.cookiejar import CookieJar


"""
Simple module to request HTTP

JinnLynn
http://jeeker.net

get(url, **kwargs)
post(url, **kwargs)
download(url, **kwargs)

Request(
    'http://jeeker.net',
    data = {},
    type = 'GET',               # GET POST default:GET
    referer = '',
    user_agent = '',
    cookie = None,              # CookieJar, Cookie.S*Cookie, dict, string
    auth = {'usr':'', 'pwd':''}, # Only Basic Authorization
    debug = False
    )
"""

_DEFAULT_TIMEOUT = 90

def get(url, **kwargs):
    kwargs.update(type='GET')
    return Request(url, **kwargs)

def post(url, **kwargs):
    kwargs.update(type='POST')
    return Request(url, **kwargs)

def download(url, local, **kwargs):
    if not local:
        raise ValueError('local filepath is empty')
    try:
        if not os.path.exists(os.path.dirname(local)):
            os.makedirs(os.path.dirname(local))
        res = Request(url, **kwargs)
        read_size = 0
        real_size = int(res.header['content-length'])
        with open(local, 'wb') as f:
            while True:
                block = res.response.read(1024*8)
                if not block:
                    break
                f.write(block)
                read_size += len(block)
        if read_size < real_size:
            raise ContentTooShortError(
                'retrieval incomplete: got only {} out of {} bytes'.formate(read_size, real_size),
                None
                )
    except Exception as e:
        raise e

class Request(object):
    def __init__(self, url, **kwargs):
        self.request = None
        self.response = None
        self.code = -1
        self.info = {}
        self.cookieJar = None
        self.reason = ''

        data = kwargs.get('data', None)
        if data:
            if isinstance(data, dict):
                data = urlencode(data)
            if not isinstance(data, basestring):
                raise ValueError('data must be string or dict')

        request_type = kwargs.get('type', 'POST')
        if data and isinstance(request_type, basestring) and request_type.upper()!='POST':
            url = '{}?{}'.format(url, data)
            data = None # GET data must be None

        self.request = urlRequest(url, data)

        # referer
        referer = kwargs.get('referer', None)
        if referer:
            self.request.add_header('referer', referer)

        # user-agent
        user_agent = kwargs.get('user_agent', None)
        if user_agent:
            self.request.add_header('User-Agent', user_agent)

        # auth
        auth = kwargs.get('auth', None)
        if auth and isinstance(auth, dict) and 'usr' in auth:
            auth_string = base64.b64encode('{}:{}'.format(auth.get('usr',''), auth.get('pwd','')))
            self.request.add_header('Authorization', 'Basic {}'.format(auth_string))  

        # cookie
        cookie = kwargs.get('cookie', None)
        cj = None
        if cookie:
            if isinstance(cookie, CookieJar):
                cj = cookie
            elif isinstance(cookie, dict):
                result = []
                for k, v in cookie.items():
                    result.append('{}={}'.format(k, v))
                cookie = '; '.join(result)
            elif isinstance(cookie, Cookie.BaseCookie):
                cookie = cookie.output(header='')
            if isinstance(cookie, basestring):
                self.request.add_header('Cookie', cookie)
        if cj is None:
            cj = CookieJar()

        #! TODO: proxy


        # build opener
        debuglevel = 1 if kwargs.get('debug', False) else 0
        opener = build_opener(
            HTTPHandler(debuglevel=debuglevel),
            HTTPSHandler(debuglevel=debuglevel),
            HTTPCookieProcessor(cj)
        )

        # timeout
        timeout = kwargs.get('timeout')
        if not isinstance(timeout, int):
            timeout = _DEFAULT_TIMEOUT

        try:
            self.response = opener.open(self.request, timeout=timeout)
            self.code = self.response.getcode()
            self.header = self.response.info().dict
            self.cookieJar = cj
        except HTTPError as e:
            self.code = e.code
            self.reason = '{}'.format(e)
            raise e
        except URLError as e:
            self.code = -1
            self.reason = e.reason
            raise e
        except Exception as e:
            self.code = -1
            self.reason = '{}'.format(e)
            raise e

    def isSuccess(self):
        return 200 <= self.code < 300

    def getContent(self):
        return self.response.read()