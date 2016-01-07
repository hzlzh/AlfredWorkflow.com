# -*- coding: utf-8 -*-
from __future__ import absolute_import, division, unicode_literals
import hashlib, random

hashDigest = lambda s: hashlib.md5(s).hexdigest()

uid = lambda: hashDigest('{}'.format(random.getrandbits(25)))