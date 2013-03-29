import os
import xml.etree.ElementTree


class Bookmark(object):
    def __init__(self, **kwargs):
        self.uuid = kwargs.get("uuid", None)
        self.child_nodes = kwargs.get("childnodes", [])
        self.isexpanded = kwargs.get("isexpanded", False)
        self.path = kwargs.get("representedobject", "")
        self.sort_order = kwargs.get("sortingorder", 1)
        self.title = kwargs.get("title", "")
        self.type_ = kwargs.get("type", "")

    def __repr__(self):
        return("<Bookmark(title=\"{0}\", representedobject=\"{1}\")>".format(
               self.title, self.path))


def get_bookmarks(f):
    bookmark_list = []

    if os.path.isfile(f):
        for bm in parse_bookmarks_file(f):
            bookmark_list.append(bm)

    return bookmark_list


def _process_elem_text(elem):
    out = None
    tag = elem.tag.lower()

    if tag == "string":
        out = elem.text
    elif tag == "true":
        out = True
    elif tag == "false":
        out = False
    elif tag == "array":
        out = []
    elif tag == "integer":
        out = int(elem.text)

    return out


def parse_bookmarks_file(f):
    tree = xml.etree.ElementTree.parse(f)
    root = tree.getroot()

    if len(root.getchildren()) == 0 or root.getchildren()[0].tag != "dict":
        return

    bm_contain = root.getchildren()[0]

    for bm_dict in bm_contain.findall("dict"):
        bm_kw = {}
        last_key = ""

        for elem in bm_dict.getchildren():
            tag = elem.tag.lower()

            if tag == "key":
                last_key = elem.text.lower()
            else:
                bm_kw[last_key] = _process_elem_text(elem)

        yield Bookmark(**bm_kw)
