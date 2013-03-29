#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright © 2013 allenm <allenm@allenmMac.local>
#

import alp
import sqlite3
import urllib2
from datetime import date

conn = sqlite3.connect('jsapi.db')
c = conn.cursor()
V = '0.0.1'

def uniMatch( matchs ):
  seen = set()
  seenAdd = seen.add
  return [ x for x in matchs if x[0] not in seen and not seenAdd( x[0] ) ]

def hasNewVersion():
  today = date.today()
  todayDate = int(today.strftime('%Y%m%d'))
  c.execute('''SELECT * FROM version WHERE date = ?''',(todayDate,))
  result = c.fetchone()
  if result is None:
    response = urllib2.urlopen('http://api.allenm.me/jsapiworkflow/version.txt')
    newV = response.read().strip()
    c.execute('''INSERT INTO version VALUES (?,?)''', ( todayDate, newV ))
    conn.commit()
  else:
    newV = result[1]

  return V != newV


def query( keyword ):

  keyword = '%'+keyword.strip()+'%'
  c.execute('''SELECT OID,* FROM jsapi WHERE name LIKE ? LIMIT 10''', ( keyword, ))

  nameMatch = c.fetchall()

  c.execute('''SELECT OID,* FROM jsapi WHERE t2 LIKE ? LIMIT 10''', ( keyword, ))
  t2Match = c.fetchall()

  allMatch = nameMatch + t2Match
  allMatch = uniMatch( allMatch )[0:10]

  items = []

  if hasNewVersion():
    item = alp.Item( title="The new js api workflow is avaliable", icon="update-icon.png", subtitle = "please choose this to download", uid="0", valid= True, autocomplete="", arg="https://github.com/allenm/jsapi-workflow")
    items.append(item)

  for index ,match in enumerate(allMatch):
    title = match[3] + ' ('+ match[2] +')'
    item = alp.Item( title= title , subtitle = match[4], uid= str(index+1 ), valid=True, autocomplete = match[3], arg= match[5] )
    items.append( item )

  alp.feedback( items )


if __name__ == "__main__":
  query('slice')

