# -*- coding: utf-8 -*-

"""
Alfred Python
A simple python module for alfred workflow。

JinnLynn
http://jeeker.net
The MIT License
"""

__version__     = '0.2'
__author__      = 'JinnLynn <eatfishlin@gmail.com>'
__license__     = 'The MIT License'
__copyright__   = 'Copyright 2013 JinnLynn'

from .core import *
from .feedback import Feedback, Item
import util, cache, config, storage