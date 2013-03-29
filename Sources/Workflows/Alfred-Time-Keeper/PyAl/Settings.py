import json
import os
from .core import *


class Settings:
    def __init__(self):
        bundleID = bundle()
        self._settingsPath = nonvolatile(bundleID + ".settings.json")
        if not os.path.exists(self._settingsPath):
            blank = {}
            with open(self._settingsPath, "w") as f:
                json.dump(blank, f)
            self._loadedSettings = blank
        else:
            with open(self._settingsPath, "r") as f:
                payload = json.load(f)
            self._loadedSettings = payload

    def set(self, **kwargs):
        for (k, v) in kwargs.iteritems():
            self._loadedSettings[k] = v
        with open(self._settingsPath, "w") as f:
            json.dump(self._loadedSettings, f)

    def get(self, k, default=None):
        try:
            return self._loadedSettings[k]
        except KeyError:
            return default

    def delete(self, k):
        try:
            if k in self._loadedSettings.keys():
                self._loadedSettings.pop(k)
                with open(self._settingsPath, "w") as f:
                    json.dump(self._loadedSettings, f)
        except Exception:
            pass
