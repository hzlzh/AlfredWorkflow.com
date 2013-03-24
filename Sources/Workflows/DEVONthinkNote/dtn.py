#coding=utf-8

import time
import subprocess
import sys
from PyAl import Feedback as F
from PyAl import Item as I


def main():
    errorNone = I(autocomplete="", valid=False,
        title="No Databases!", subtitle="No DEVONthink databases were found.")

    q = sys.argv[1]
    (pathQuery, sep, noteQuery) = q.rpartition("→")
    if not noteQuery.startswith(" "):
        noteQuery = "NONOTES"

    theDBs = subprocess.check_output(["osascript", "getDBs.scpt"])
    theDBs = theDBs[:-1]
    theDBs = theDBs.split(", ")
    if not len(theDBs):
        print F(errorNone)

    if pathQuery == "":
        if len(theDBs):
            items = []
            for aDB in theDBs:
                items.append(I(uid=aDB, valid=False, autocomplete=aDB + u"→",
                    title=aDB, subtitle="Add note to %s." % aDB))
        else:
            items = errorNone
        print F(items)
    elif len(pathQuery) > 1 and noteQuery == "NONOTES":
        path = pathQuery
        path = path.decode('utf-8')
        pathElements = path.split(u"→")
        if pathElements[-1] == "":
            pathElements.pop()
        if pathElements[-1] in theDBs:
            cmd = "osascript getGroups.scpt \"%s\"" % pathElements[-1]
            theParents = subprocess.check_output(cmd, shell=True)
            theParents = theParents[:-1]
            theParents = theParents.split(", ")
            items = []
            for aParent in theParents:
                items.append(I(valid=False, autocomplete=path + u"→" + aParent + u"→",
                    title=aParent, subtitle="Create a note or select a group in '%s'." % aParent))
        else:
            theDB = pathElements[0]
            theParent = pathElements[-1]
            children = subprocess.check_output(["osascript", "getChildren.scpt", theDB, theParent])
            children = children[:-1]
            if children == "NONE":
                items = I(valid=False, autocomplete=path + " ",
                    title=theParent, subtitle="Create a note in '%s'." % theParent)
            else:
                childList = children.split(", ")
                items = []
                for aChild in childList:
                    items.append(I(valid=False, autocomplete=path + u"→" + aChild + u"→",
                        title=aChild, subtitle="Create a note or select a group in '%s'." % aChild))
        print F(items)

    else:
        path = pathQuery
        path = path.decode('utf-8')
        pathElements = path.split(u"→")
        note = noteQuery
        theDB = pathElements[0]
        theGroup = pathElements[-1]

        if theGroup == theDB:
            theGroup = "Inbox"

        if ":" in note:
            (title, colon, note) = note.partition(": ")
        else:
            title = "Note: " + time.strftime("%Y-%m-%d @ %I:%M%p")

        items = I(valid=True, arg="%s ||| %s ||| %s ||| %s" % (theDB, theGroup, title, note), title=title, subtitle=note)

        print F(items)


if __name__ == "__main__":
    main()
