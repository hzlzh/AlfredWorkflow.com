#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
    requests_cache.backends.redisdict
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    Dictionary-like objects for saving large data sets to ``redis`` key-store
"""
from collections import MutableMapping
try:
    import cPickle as pickle
except ImportError:
    import pickle
from alp.request.requests_cache.backends.redis import StrictRedis as Redis


class RedisDict(MutableMapping):
    """ RedisDict - a dictionary-like interface for ``redis`` key-stores
    """
    def __init__(self, namespace, collection_name='redis_dict_data',
                 connection=None):
        """
        The actual key name on the redis server will be
        ``namespace``:``collection_name``

        In order to deal with how redis stores data/keys,
        everything, i.e. keys and data, must be pickled.

        :param namespace: namespace to use
        :param collection_name: name of the hash map stored in redis
                                (default: redis_dict_data)
        :param connection: ``redis.StrictRedis`` instance.
                           If it's ``None`` (default), a new connection with
                           default options will be created

        """
        if connection is not None:
            self.connection = connection
        else:
            self.connection = Redis()
        self._self_key = ':'.join([namespace, collection_name])

    def __getitem__(self, key):
        result = self.connection.hget(self._self_key, pickle.dumps(key))
        if result is None:
            raise KeyError
        return pickle.loads(bytes(result))

    def __setitem__(self, key, item):
        self.connection.hset(self._self_key, pickle.dumps(key),
                             pickle.dumps(item))

    def __delitem__(self, key):
        if not self.connection.hdel(self._self_key, pickle.dumps(key)):
            raise KeyError

    def __len__(self):
        return self.connection.hlen(self._self_key)

    def __iter__(self):
        for v in self.connection.hkeys(self._self_key):
            yield pickle.loads(bytes(v))

    def clear(self):
        self.connection.delete(self._self_key)

    def __str__(self):
        return str(dict(self.items()))
