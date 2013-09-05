# -*- coding: utf-8 -*-
import os, json, time, shutil, codecs

import core
##
# {
#     'expire_time'    : 0,
#     'data'           : {} 
# }

CACHE_FOLDER = os.path.expanduser('~/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/')

CACHE_DEFAULT_EXPIRE = 60 * 60 * 24

class Cache(object):
    def __init__(self):
        self.cache_dir = os.path.join(CACHE_FOLDER, core.bundleID())
        if not os.path.exists(self.cache_dir):
            os.makedirs(self.cache_dir)

    def getFilepath(self, name):
        return os.path.join(self.cache_dir, '{}.json'.format(name))

    def getContent(self, name):
        try:
            path = self.getFilepath(name)
            with codecs.open(path, 'r', 'utf-8') as f:
                return json.load(f)
        except:
            pass
    
    def get(self, name):
        try:
            cache = self.getContent(name)
            if cache['expire_time'] >= time.time():
                return cache['data']
        except:
            pass
        self.delete(name)
        
    def set(self, name, data, expire=CACHE_DEFAULT_EXPIRE):
        path = self.getFilepath(name)
        try:
            cache = {
                    'expire_time'   : time.time() + expire,
                    'data'          : data
                }
            with codecs.open(path, 'w', 'utf-8') as f:
                json.dump(cache, f)
        except:
            pass

    def delete(self, name):
        path = self.getFilepath(name)
        if os.path.exists(path):
            os.remove(path)

    def clean(self):
        shutil.rmtree(self.cache_dir)

    def expireTimeout(self, name):
        try:
            cache = self.getContent(name)
            if cache['expire_time'] >= time.time():
                return cache['expire_time'] - time.time()
        except:
            pass
        return -1