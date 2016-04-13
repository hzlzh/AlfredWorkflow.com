from __future__ import unicode_literals

from .helpers import use_appropriate_encoding


class Channel(object):

    def __init__(self, account, channel_info):
        self._account = account
        self.channel_tag = channel_info.get("tag")

        for attr in ("name", "description", "created", "modified"):
            setattr(self, attr, channel_info.get(attr))

    def push_note(self, title, body):
        data = {"type": "note", "title": title, "body": body}
        return self._push(data)

    def push_address(self, name, address):
        data = {"type": "address", "name": name, "address": address}
        return self._push(data)

    def push_list(self, title, items):
        data = {"type": "list", "title": title, "items": items}
        return self._push(data)

    def push_link(self, title, url, body=None):
        data = {"type": "link", "title": title, "url": url, "body": body}
        return self._push(data)

    def push_file(self, file_name, file_url, file_type, body=None):
        return self._account.push_file(file_name, file_url, file_type, body, channel=self)

    def _push(self, data):
        data["channel_tag"] = self.channel_tag
        return self._account._push(data)

    @use_appropriate_encoding
    def __str__(self):
        return "Channel(name: '{0}' tag: '{1}')".format(self.name, self.channel_tag)

    def __repr__(self):
        return self.__str__()
