# -*- coding: utf-8 -*-
import glob
import os
import sqlite3
import time

import alfred

_CACHE_EXPIRY = 24 * 60 * 60 # in seconds
_CACHE = alfred.work(True)

def combine(operator, iterable):
    return u'(%s)' % (' %s ' % operator).join(iterable)

def icon(uid, data):
    icon = os.path.join(_CACHE, 'icon-%d.png' % uid)
    if (not os.path.exists(icon)) or ((time.time() - os.path.getmtime(icon)) > _CACHE_EXPIRY):
        open(icon, 'wb').write(data)
    return icon

def places(profile):
    profile = [d for d in glob.glob(os.path.expanduser(profile)) if os.path.isdir(d)][0]
    return os.path.join(profile, 'places.sqlite')

def results(db, query):
    for (uid, title, url, data) in db.execute(sql(query)):
        yield alfred.Item({u'uid': alfred.uid(uid), u'arg': url}, title, url, icon(uid, data))

def sql(query):
    subqueryTemplate = u"""\
select moz_places.id, moz_places.title, moz_places.url, moz_favicons.data from moz_places
%s
where %s"""
    joinTemplate = u"""\
inner join %(table)s on moz_places.id = %(table)s.%(field)s
inner join moz_favicons on moz_places.favicon_id = moz_favicons.id"""
    tablesAndFields = [(u'moz_inputhistory', u'place_id'), (u'moz_bookmarks', u'id')]
    return u'\nunion\n'.join(
        subqueryTemplate % (joinTemplate % locals(), where(query))
        for (table, field) in tablesAndFields
    )

def where(query):
    words = [word.replace(u"'", u"''") for word in query.split(u' ')]
    return combine(u'or', (
        combine(u'and', ((u"(moz_places.%s like '%%%s%%')" % (field, word)) for word in words))
        for field in (u'title', u'url'))
    )

(profile, query) = alfred.args()
db = sqlite3.connect(places(profile))
alfred.write(alfred.xml(results(db, query)))
