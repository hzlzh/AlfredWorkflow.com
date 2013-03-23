#!/usr/bin/python
from alfred import Feedback
from BeautifulSoup import BeautifulSoup as BS
import urllib2
import string
import sys

fb = Feedback()
term = ' '.join(sys.argv[1:])
with file('username.txt', 'rb') as f:
    username = f.read()

def pin_search(query,username):
  URL = 'http://www.pinboard.in/search/u:%s?query=%s' % (username,query)
  soup = BS(urllib2.urlopen(URL))
  for link in soup("a"):
    if "bookmark_title" in str(link):
      fb.add_item(link.string.strip(), subtitle=link['href'], arg=link['href'])
  print fb

if term[0:4] == "set ":
  username = term[4:]
  with file('username.txt', 'wb') as f:
    f.write(username)
  fb.add_item("Pinboard username set to %s" % username)
  print fb
elif len(term) > 3 and term[0:4] != "set ":
  pin_search(sys.argv[1:], username)
else:
  fb.add_item("Search results for %s shown for 4 or more characters" % username )
  print fb


