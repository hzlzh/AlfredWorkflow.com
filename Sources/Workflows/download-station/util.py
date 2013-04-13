# -*- coding: utf-8 -*-
import urllib, base64
from rdl import RealDownloadLink

def parseURIInfo(uri, is_base64encode = False):
    if not isinstance(uri, (str, unicode)):
        return []
    if is_base64encode:
        uri = base64.b64decode(uri)
    tmp_uris = uri.split('\n')
    uris = []
    for uri in tmp_uris:
        uris.extend(uri.split(','))

    parsed_uris = []
    rdl = RealDownloadLink()
    for uri in uris:
        parsed_uris.append(rdl.parse(uri))
    return parsed_uris

def toFloat(s):
    try:
        return float(s)
    except:
        return 0.0

def toInt(s):
    try:
        return int(s)
    except:
        return 0