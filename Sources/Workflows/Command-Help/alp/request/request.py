import alp.core as core
from bs4 import BeautifulSoup
import requests
import requests_cache


class Request(object):
    def __init__(self, url, payload=None, post=False):
        bundleID = core.bundle()
        cacheName = core.cache(bundleID + "_requests_cache")
        requests_cache.configure(cacheName)
        if payload:
            self.request = requests.get(url, params=payload) if not post else requests.post(url, data=payload)
        else:
            self.request = requests.get(url)

    def souper(self):
        if self.request.status_code == requests.codes.ok:
            return BeautifulSoup(self.request.text)
        else:
            self.request.raise_for_status()
