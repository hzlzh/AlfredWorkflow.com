# -*- coding: utf-8 -*-
import os, json, time, shutil

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

    def getCacheFile(self, name):
        return os.path.join(self.cache_dir, '{}.json'.format(name))
    
    def get(self, name):
        path = self.getCacheFile(name)
        if not os.path.exists(path):
            return
        try:
            with open(path, 'r') as f:
                cache = json.load(f)
        except Exception, e:
            os.remove(path)
            return
        # 过期
        if time.time() > cache['expire_time']:
            os.remove(path)
            return
        return cache['data']
        
    def set(self, name, data, expire = CACHE_DEFAULT_EXPIRE):
        path = self.getCacheFile(name)
        try:
            with open(path, 'w') as f:
                cache = {
                    'expire_time'   : time.time() + expire,
                    'data'          : data
                }
                json.dump(cache, f)
        except Exception, e:
            pass

    def delete(self, name):
        path = self.getCacheFile(name)
        if os.path.exists(path):
            os.remove(path)

    def clean(self):
        shutil.rmtree(self.cache_dir)