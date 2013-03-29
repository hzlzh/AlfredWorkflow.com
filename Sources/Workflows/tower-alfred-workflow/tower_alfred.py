import os

import alp
import tower

BOOKMARKS_FILE_STR = "~/Library/Application Support/Tower/Bookmarks.plist"

BOOKMARKS_FILE = os.path.expanduser(BOOKMARKS_FILE_STR)


def _get_bookmark_for_title(bookmarks, title):
    for b in bookmarks:
        if b.title.lower() == title.lower():
            return b


def get_results(arg):
    """ Returns a list of Bookmark objects after a
    title search based on the given arg """
    bookmarks = tower.get_bookmarks(BOOKMARKS_FILE)

    # alp.fuzzy_search() will break if query is ""
    if arg == "":
        # only use sort_order when no arguments are given
        # otherwise, we'll use alp's ranking system
        results = sorted(bookmarks, key=lambda x: x.sort_order)
    else:
        titles = alp.fuzzy_search(arg, bookmarks, key=lambda x: x.title)
        paths = alp.fuzzy_search(arg, bookmarks, key=lambda x: x.path)
        results = set(titles).union(set(paths))

    return results


def get_items(arg):
    """ Get a list of alfred.Item objects """

    items = []

    for count, bookmark in enumerate(get_results(arg)):
        items.append(alp.Item(
            title=bookmark.title,
            subtitle=bookmark.path,
            arg=bookmark.path,
            icon="CloneRepoIcon.png")
        )

    return items
