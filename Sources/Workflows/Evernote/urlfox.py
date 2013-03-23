#!/usr/bin/python

import os, os.path, glob
import sys

sys.excepthook = lambda a,b,c: None # do nothing, just quit

sessionfns = []
for sessionfn in glob.glob(os.path.expanduser("~") + "/Library/Application Support/Firefox/Profiles/*/sessionstore.js"):
	sessionfns += [(os.stat(sessionfn).st_mtime, sessionfn)]

sessionfn = max(sessionfns)[1]

s = eval(open(sessionfn).read(), {"false":False,"true":True})

selectedWindow = s["selectedWindow"]
w = s["windows"][selectedWindow - 1]

selectedTab = w["selected"]
t = w["tabs"][selectedTab - 1]

def lastEntryOfTab(t):
	numEntries = len(t["entries"])
	e = t["entries"][numEntries - 1]
	return e["url"]

print lastEntryOfTab(t)

#import code
#code.interact(local=locals())