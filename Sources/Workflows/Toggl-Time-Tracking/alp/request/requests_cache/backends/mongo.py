#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
    requests_cache.backends.mongo
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    ``mongo`` cache backend
"""
from .base import BaseCache
from .mongodict import MongoDict, MongoPickleDict


class MongoCache(BaseCache):
    """ ``mongo`` cache backend.
    """
    def __init__(self, db_name='requests-cache', **options):
        """
        :param db_name: database name (default: ``'requests-cache'``)
        :param connection: (optional) ``pymongo.Connection``
        """
        super(MongoCache, self).__init__()
        self.responses = MongoPickleDict(db_name, 'responses',
                                         options.get('connection'))
        self.url_map = MongoDict(db_name, 'urls', self.responses.connection)

