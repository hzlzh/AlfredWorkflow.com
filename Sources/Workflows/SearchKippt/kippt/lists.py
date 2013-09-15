import requests
import json


class Lists:
    """Lists class

    Handles the lists endpoint of the Kippt API.
    """
    def __init__(self, kippt):
        """ Instantiates a Lists object.

        Parameters:
        kippt - KipptAPI object

        """
        self.kippt = kippt

    def all(self, **args):
        """ Return all Lists.

        """
        limit = args['limit'] if 'limit' in args else 20
        offset = args['offset'] if 'offset' in args else 0

        r = requests.get(
            "https://kippt.com/api/lists?limit=%s&offset=%s" % (limit, offset),
            headers=self.kippt.header
        )
        return (r.json())

    def search(self, query, **args):
        """ Search for a list.

        Parameters:
        - query String we are searching for.

        """
        limit = args['limit'] if 'limit' in args else 20
        offset = args['offset'] if 'offset' in args else 0

        r = requests.get(
            "https://kippt.com/api/lists/search?q=%s&limit=%s&offset=%s" % (query, limit, offset),
            headers=self.kippt.header
        )
        return (r.json())

    def create(self, title, **args):
        """ Create a new Kippt List.

        Parameters:
        - title (Required)
        - args Dictionary of other fields

        Accepted fields can be found here:
            https://github.com/kippt/api-documentation/blob/master/objects/list.md
        """
        # Merge our title as a parameter and JSONify it.
        data = json.dumps(dict({'title': title}, **args))
        r = requests.post(
            "https://kippt.com/api/lists",
            headers=self.kippt.header,
            data=data
        )
        return (r.json())

    def list(self, id):
        return List(self.kippt, id)


class List:
    """List class

    Instantiates a List object.

    """

    def __init__(self, kippt, id):
        """ Instantiates a List object.

        """
        self.kippt = kippt
        self.id = id

    def content(self):
        """ Retrieves content of list.

        """
        r = requests.get(
            "https://kippt.com/api/lists/%s" % (self.id),
            headers=self.kippt.header
        )
        return (r.json())

    def clips(self, **args):
        """ Retrives clips in a list.

        """
        limit = args['limit'] if 'limit' in args else 20
        offset = args['offset'] if 'offset' in args else 0

        r = requests.get(
            "https://kippt.com/api/lists/%s/clips?limit=%s&offset=%s" % (self.id, limit, offset),
            headers=self.kippt.header
        )
        return (r.json())

    def relationship(self):
        """ Retrieves the relationship the authenticated user
        has with the list.

        """
        r = requests.get(
            "https://kippt.com/api/lists/%s/relationship" % (self.id),
            headers=self.kippt.header
        )
        return (r.json())

    def update(self, **args):
        """ Updates a List.

        Parameters:
        - args Dictionary of other fields

        Accepted fields can be found here:
            https://github.com/kippt/api-documentation/blob/master/objects/list.md
        """
        # JSONify our data.
        data = json.dumps(args)
        r = requests.put(
            "https://kippt.com/api/lists/%s" % (self.id),
            headers=self.kippt.header,
            data=data
        )
        return (r.json())

    def follow(self):
        """ Follow a list.

        """
        data = json.dumps({"action": "follow"})
        r = requests.post(
            "https://kippt.com/api/lists/%s/relationship" % (self.id),
            headers=self.kippt.header,
            data=data
        )
        return (r.json())

    def unfollow(self):
        """ Unfollow a list.

        """
        data = json.dumps({"action": "unfollow"})
        r = requests.post(
            "https://kippt.com/api/lists/%s/relationship" % (self.id),
            headers=self.kippt.header,
            data=data
        )
        return (r.json())

    def delete(self):
        """ Delete a list.

        """
        requests.delete(
            "https://kippt.com/api/lists/%s" % (self.id),
            headers=self.kippt.header
        )
        # This request doesn't return anything - but let's be
        # consistent and return an empty JSON object.
        return (json.dumps({}))
