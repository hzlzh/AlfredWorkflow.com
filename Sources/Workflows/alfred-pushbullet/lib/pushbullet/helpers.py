from __future__ import unicode_literals

import sys


def use_appropriate_encoding(fn):

    if sys.version_info[0] < 3:
        def _fn(*args, **kwargs):
            return fn(*args, **kwargs).encode(sys.stdout.encoding or 'utf-8')
        return _fn
    else:
        return fn
