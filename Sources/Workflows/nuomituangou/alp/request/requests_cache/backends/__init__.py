#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
    requests_cache.backends
    ~~~~~~~~~~~~~~~~~~~~~~~

    Classes and functions for cache persistence
"""


from .base import BaseCache

registry = {
    'memory': BaseCache,
}

try:
    # Heroku doesn't allow the SQLite3 module to be installed
    from alp.request.requests_cache.backends.sqlite import DbCache
    registry['sqlite'] = DbCache
except ImportError:
    DbCache = None

try:
    from alp.request.requests_cache.backends.mongo import MongoCache
    registry['mongo'] = registry['mongodb'] = MongoCache
except ImportError:
    MongoCache = None

try:
    from alp.request.requests_cache.backends.redis import RedisCache
    registry['redis'] = RedisCache
except ImportError:
    RedisCache = None
