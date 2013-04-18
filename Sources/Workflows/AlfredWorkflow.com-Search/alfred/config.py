# -*- coding: utf-8 -*-
import os, json, codecs

import core

_config_dir = os.path.join(core._CONFIG_FOLDER, core.bundleID())

def _getFilepath():
    if not os.path.exists(_config_dir):
        os.makedirs(_config_dir)
    return os.path.join(_config_dir, 'config.json')

def _save(configs):
    filepath = _getFilepath()
    with codecs.open(filepath, 'w', 'utf-8') as f:
        json.dump(configs, f, indent=4)

def getAll():
    filepath = _getFilepath()
    try:
        with codecs.open(filepath, 'r', 'utf-8') as f:
            return json.load(f)
    except:
        pass
    return {}

def get(key, default=None):
    configs = getAll()
    return configs.get(key, default)

def set(**kwargs):
    configs = getAll()
    for (k, v) in kwargs.iteritems():
        configs[k] = v
    _save(configs)

def delete(key):
    configs = getAll()
    if not configs.has_key(key):
        return
    configs.pop(key)
    _save(configs)

def clean():
    filepath = _getFilepath()
    if os.path.exists(filepath):
        os.remove(filepath)