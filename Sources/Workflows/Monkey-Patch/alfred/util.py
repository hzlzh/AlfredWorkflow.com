# -*- coding: utf-8 -*-

import hashlib, random

import core

hashDigest = lambda s: hashlib.md5(s).hexdigest()

uid = lambda: '{0}.{1}'.format(core.bundleID(), random.getrandbits(25))