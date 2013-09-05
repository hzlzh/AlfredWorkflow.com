# -*- coding: utf-8 -*-
import os, json, time, shutil, codecs
import hashlib

import core, util

# { 'expire_time' : 0, name: '', data' : {} }

_DEFAULT_EXPIRE = 60 * 60 * 24

_cache_dir = os.path.join(core._CACHE_FOLDER, core.bundleID())

def _getFilepath(name):
    if not os.path.exists(_cache_dir):
        os.makedirs(_cache_dir)
    # convert to md5, more safe for file name
    return os.path.join(_cache_dir, '{}.json'.format(util.hashDigest(name)))

def _getContent(name):
    try:
        filepath = _getFilepath(name)
        with codecs.open(filepath, 'r', 'utf-8') as f:
            return json.load(f)
    except:
        pass

def set(name, data, expire=_DEFAULT_EXPIRE):
    filepath = _getFilepath(name)
    try:
        cache = {
            'expire_time'   : time.time() + expire,
            'name'          : name,
            'data'          : data
            }
        with codecs.open(filepath, 'w', 'utf-8') as f:
            json.dump(cache, f, indent=4)
    except:
        pass

def get(name):
    try:
        cache = _getContent(name)
        if cache['expire_time'] >= time.time():
            return cache['data']
    except:
        pass
    delete(name)

def delete(name):
    cache_file = _getFilepath(name)
    if os.path.exists(cache_file):
        os.remove(cache_file)

def clean():
    if os.path.exists(_cache_dir):
        shutil.rmtree(_cache_dir)

def timeout(name):
    try:
        cache = _getContent(name)
        if cache['expire_time'] >= time.time():
            return cache['expire_time'] - time.time()
    except:
        pass
    return -1