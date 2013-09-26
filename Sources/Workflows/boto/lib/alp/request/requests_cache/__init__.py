#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
    requests_cache
    ~~~~~~~~~~~~~~

    Transparent cache for ``requests`` library with persistence and async support

    Just write::

        import requests_cache
        requests_cache.install_cache()

    And requests to resources will be cached for faster repeated access::

        import requests
        for i in range(10):
            r = requests.get('http://httpbin.org/delay/5')
        # will took  approximately 5 seconds instead 50


    :copyright: (c) 2012 by Roman Haritonov.
    :license: BSD, see LICENSE for more details.
"""
__docformat__ = 'restructuredtext'
__version__ = '0.3.0'

from alp.request.requests_cache.core import(
    CachedSession, install_cache, uninstall_cache,
    disabled, get_cache, clear, configure
)
