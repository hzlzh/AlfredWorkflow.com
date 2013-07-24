import alp
from alp import Item

query = "{query}"

item = Item(
            uid=alp.bundle(),
            arg='',
            valid=True,
            title=query,
            subtitle='set username for delicious',
            icon='logo.png')

alp.feedback([item])

# =========================

import os
from alp import core

query = "{query}"

infoPath = os.path.abspath("./info.plist")

plist = core.readPlist(infoPath)

plist['username'] = query

core.writePlist(plist, infoPath)
