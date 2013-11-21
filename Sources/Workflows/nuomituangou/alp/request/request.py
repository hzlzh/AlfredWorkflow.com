import alp.core as core
from bs4 import BeautifulSoup
import requests
import requests_cache


class Request(object):
    def __init__(self, url, payload=None, post=False, cache=True, cache_for=None):
        self.url = url
        self.payload = payload
        self.post = post
        self.cache_for = cache_for
        self.ok = False
        self.cache = cache
        self.cache_name = None

    def download(self):
        self.cache_name = core.cache("requests_cache")
        if self.cache_for != None and self.cache_for < 0:
            exp = None
        else:
            exp = self.cache_for or 24 * (60^2)
        if self.cache:
            requests_cache.install_cache(self.cache_name, expire_after=exp, allowable_methods=('GET','POST'))
        if self.payload:
            self.request = requests.get(self.url, params=self.payload) if not self.post else requests.post(self.url, data=self.payload)
        else:
            self.request = requests.get(self.url)

        self.ok = self.request.status_code == requests.codes.ok

    def souper(self):
        if self.request.status_code == requests.codes.ok:
            return BeautifulSoup(self.request.text)
        else:
            self.request.raise_for_status()

    def clear_cache(self):
        if self.cache_name:
            requests_cache.clear()
        self.download()
