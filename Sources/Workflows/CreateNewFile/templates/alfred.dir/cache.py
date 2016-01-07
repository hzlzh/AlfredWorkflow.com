# -*- coding: utf-8 -*-
from __future__ import absolute_import, division, unicode_literals
import os, json, time, shutil, codecs
import hashlib

from . import util
from . import core

# { 'expire_time' : 0, name: '', data' : {} }

_DEFAULT_EXPIRE = 60 * 60 * 24

_cache_dir = os.path.join(core._cache_base_dir, core.bundleID())

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

def get(name, default=None):
    try:
        cache = _getContent(name)
        if cache['expire_time'] >= time.time():
            return cache['data']
    except:
        pass
    delete(name)
    return default

def delete(name):
    cache_file = _getFilepath(name)
    if os.path.exists(cache_file):
        os.remove(cache_file)

def clean():
    cache_dir = os.path.join(core._cache_base_dir, core.bundleID())
    if os.path.exists(cache_dir):
        shutil.rmtree(cache_dir)

def cleanExpired():
    if not os.path.exists(_cache_dir):
        return
    to_remove = []
    for f in os.listdir(_cache_dir):
        if not f.endswith('.json'):
            continue
        filepath = os.path.join(_cache_dir, f)
        try:
            with codecs.open(filepath, 'r', 'utf-8') as fp:
                cache = json.load(fp)
                if cache['expire_time'] < time.time():
                    to_remove.append(filepath)
        except Exception, e:
            to_remove.append(filepath)
    for f in to_remove:
        os.remove(f)
        
def timeout(name):
    try:
        cache = _getContent(name)
        if cache['expire_time'] >= time.time():
            return cache['expire_time'] - time.time()
    except:
        pass
    return -1