# -*- coding: utf-8 -*-
import os, json, codecs

import core

CONFIG_FOLDER = os.path.expanduser('~/Library/Application Support/Alfred 2/Workflow Data/')

class Config(object):
    def __init__(self, config_file = 'config.json'):
        self.configs = {}
        self.configFile = ''
        path = os.path.join(CONFIG_FOLDER, core.bundleID())
        if not os.path.exists(path):
            os.makedirs(path)
        self.configFile = os.path.join(path, config_file)
        if os.path.exists(path):
            try:
                with codecs.open(self.configFile, 'r', 'utf-8') as f:
                    self.configs = json.load(f)
            except Exception, e:
                pass
        if not isinstance(self.configs, dict):
            self.configs = {}

    def save(self):
        with codecs.open(self.configFile, 'w', 'utf-8') as f:
            json.dump(self.configs, f)
        
    def get(self, key, default = None):
        return self.configs.get(key, default)

    def set(self, **kwargs):
        for (k, v) in kwargs.iteritems():
            self.configs[k] = v
        self.save()

    def delete(self, key):
        if not self.configs.has_key(key):
            return
        self.configs.pop(key)
        self.save()

    def clean(self):
        self.configs = {}
        self.save()