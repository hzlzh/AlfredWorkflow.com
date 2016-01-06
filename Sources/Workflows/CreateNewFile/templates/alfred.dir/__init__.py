# -*- coding: utf-8 -*-
'''
Alfred Python
A simple python module for alfred workflow。

JinnLynn
http://jeeker.net
The MIT License

For more information, see the project page:
https://github.com/JinnLynn/alfred-python
'''
from __future__ import absolute_import, division, unicode_literals

__version__     = '0.3.1'
__author__      = 'JinnLynn <eatfishlin@gmail.com>'
__license__     = 'The MIT License'
__copyright__   = 'Copyright 2013 JinnLynn'

from .core import *
from .feedback import Feedback, Item
from . import util
from . import cache
from . import config
from . import storage
from . import request
