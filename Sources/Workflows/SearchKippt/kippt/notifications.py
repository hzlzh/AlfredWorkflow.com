import requests
import json


class Notifications:
    """Notifications class

    Handles the notifications endpoint of the Kippt API.
    """
    def __init__(self, kippt):
        """ Instantiates a Notifications object.

        Parameters:
        kippt - KipptAPI object

        """
        self.kippt = kippt

    def get(self, **args):
        """ Return all Notifications.

        """
        limit = args['limit'] if 'limit' in args else 20
        offset = args['offset'] if 'offset' in args else 0

        r = requests.get(
            "https://kippt.com/api/notifications?limit=%s&offset=%s" % (limit, offset),
            headers=self.kippt.header
        )
        return (r.json())

    def mark_read(self):
        """ Mark notifications as read.

        CURRENT UNSUPPORTED:
        https://github.com/kippt/api-documentation/blob/master/endpoints/notifications/POST_notifications.md

        """
        # Obviously remove the exception when Kippt says the support it.
        raise NotImplementedError(
            "The Kippt API does not yet support marking notifications as read."
        )

        data = json.dumps({"action": "mark_seen"})
        r = requests.post(
            "https://kippt.com/api/notifications",
            headers=self.kippt.header,
            data=data
        )
        return (r.json())
