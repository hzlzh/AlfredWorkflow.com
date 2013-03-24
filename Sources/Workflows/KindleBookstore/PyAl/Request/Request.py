from PyAl.core import *
from bs4 import BeautifulSoup
import requests
import requests_cache


class Request:
    def __init__(self, url, payload=None, post=False):
        bundleID = bundle()
        cacheName = volatile(bundleID + "_requests_cache")
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
