import os
import deliciousapi
import alp
from alp import Item, core


def bookmarks2items(bookmarks):
    items = []
    for bookmark in bookmarks:
        item = Item(
            uid=alp.bundle(),
            arg=bookmark[0],
            valid=True,
            title=bookmark[2],
            subtitle=bookmark[1][0],
            icon='logo.png')
        items.append(item)
    return items

dapi = deliciousapi.DeliciousAPI()

query = "{query}"

infoPath = os.path.abspath("./info.plist")

plist = core.readPlist(infoPath)

DEFAULT_USERNAME = plist['username']

if query:
    bookmarks = dapi.get_user_with_tag(DEFAULT_USERNAME, query, max_bookmarks=10).bookmarks
else:
    bookmarks = dapi.get_user(DEFAULT_USERNAME, max_bookmarks=10).bookmarks

items = bookmarks2items(bookmarks)

alp.feedback(items)
