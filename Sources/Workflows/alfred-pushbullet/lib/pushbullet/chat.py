from __future__ import unicode_literals

from .helpers import use_appropriate_encoding
from .device import Device


class Chat(Device):

    def __init__(self, account, chat_info):
        self._account = account
        self.iden = chat_info.get("iden")

        contact_info = chat_info['with']
        for attr in ("created", "modified"):
            setattr(self, attr, chat_info.get(attr))
        for attr in ("name", "email", "email_normalized", "image_url"):
            setattr(self, attr, contact_info.get(attr))

    def _push(self, data):
        data["email"] = self.email
        return self._account._push(data)

    @use_appropriate_encoding
    def __str__(self):
        return "Chat('{0}' <{1}>)".format(self.name, self.email_normalized)
