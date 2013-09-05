# Date:     June 12, 2013
# Author:   Benjamin Gray
# Purpose:  Searches anki note fields and displays question and answer in alfred

import alfred
import sqlite3
import string

MAX_RESULTS = 50

(pathToCollection, query) = alfred.args()

# get the cards from the database
db = sqlite3.connect(pathToCollection)
q = "select flds, id from notes where flds like '%" + query + "%'"
rs = db.execute(q)
results = []
for r in rs:
    string = r[0]
    cid = unicode(r[1])
    fields = string.split("\x1f")
    question = fields[0]
    answer = fields[1]

    # write results to item list
    results.append( alfred.Item(
                       attributes= {'uid': alfred.uid(0), 'arg': cid},
                       title=question,
                       subtitle=answer,
                                icon='Anki.png'
                       )) # a single Alfred result

# compiles xml response for alfred
xml = alfred.xml(results, MAX_RESULTS)
alfred.write(xml)