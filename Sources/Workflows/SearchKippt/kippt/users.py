import requests
import json


class Users:
    """Users class

    Handles the users endpoint of the Kippt API.

    """

    def __init__(self, kippt):
        """ Instantiates a Users object.

        Parameters:
        kippt - KipptAPI object

        """
        self.kippt = kippt

    def search(self, query, **args):
        """ Search for a user.

        Parameters:
        - query String we are searching for.

        """
        limit = args['limit'] if 'limit' in args else 20
        offset = args['offset'] if 'offset' in args else 0

        r = requests.get(
            "https://kippt.com/api/users/search?q=%s&limit=%s&offset=%s" % (query, limit, offset),
            headers=self.kippt.header
        )
        return (r.json())

    def user(self, id):
        return User(self.kippt, id)


class User:
    """ User class

    Handles the User object.
    """

    def __init__(self, kippt, id):
        self.kippt = kippt
        self.id = id

    def profile(self):
        """ Retrieve a user's profile.

        """
        r = requests.get(
            "https://kippt.com/api/users/%s" % (self.id),
            headers=self.kippt.header
        )
        return (r.json())

    def followers(self, **args):
        """ Retrieve a user's followers.

        """
        limit = args['limit'] if 'limit' in args else 20
        offset = args['offset'] if 'offset' in args else 0

        r = requests.get(
            "https://kippt.com/api/users/%s/followers?limit=%s&offset=%s" % (self.id, limit, offset),
            headers=self.kippt.header
        )
        return (r.json())

    def following(self, **args):
        """ Retrieve who a user is following.

        """
        limit = args['limit'] if 'limit' in args else 20
        offset = args['offset'] if 'offset' in args else 0

        r = requests.get(
            "https://kippt.com/api/users/%s/following?limit=%s&offset=%s" % (self.id, limit, offset),
            headers=self.kippt.header
        )
        return (r.json())

    def clips(self, **args):
        """ Retrieve the user's public clips.

        """
        limit = args['limit'] if 'limit' in args else 20
        offset = args['offset'] if 'offset' in args else 0

        r = requests.get(
            "https://kippt.com/api/users/%s/clips?limit=%s&offset=%s" % (self.id, limit, offset),
            headers=self.kippt.header
        )
        return (r.json())

    def favorited_clips(self, **args):
        """ Retrieve the user's publicly favorited clips.

        """
        limit = args['limit'] if 'limit' in args else 20
        offset = args['offset'] if 'offset' in args else 0

        r = requests.get(
            "https://kippt.com/api/users/%s/clips/favorites?limit=%s&offset=%s" % (self.id, limit, offset),
            headers=self.kippt.header
        )
        return (r.json())

    def liked_clips(self, **args):
        """ Retrieve the user's publicly liked clips.

        """
        limit = args['limit'] if 'limit' in args else 20
        offset = args['offset'] if 'offset' in args else 0

        r = requests.get(
            "https://kippt.com/api/users/%s/clips/likes?limit=%s&offset=%s" % (self.id, limit, offset),
            headers=self.kippt.header
        )
        return (r.json())

    def lists(self, **args):
        """ Retrieve the user's public lists.

        """
        limit = args['limit'] if 'limit' in args else 20
        offset = args['offset'] if 'offset' in args else 0

        r = requests.get(
            "https://kippt.com/api/users/%s/lists?limit=%s&offset=%s" % (self.id, limit, offset),
            headers=self.kippt.header
        )
        return (r.json())


    # This one is weird - but from their documentation:
    #
    # "This endpoint return user's list.
    # This endpoint is somewhat redundant with /api/lists/:list_id/ if used with numeric list_id.
    # The reason for the existence of this endpoint is that it can be mapped to URLs.
    # This is important for Kippt's web client for most likely useless for everyone else."
    # https://github.com/kippt/api-documentation/blob/master/endpoints/users/GET_users_id_lists_id.md
    #
    def list(self, list_id):
        """ Retrieve the list given for the user.

        """

        r = requests.get(
            "https://kippt.com/api/users/%s/lists/%s" % (self.id, list_id),
            headers=self.kippt.header
        )
        return (r.json())

    def relationship(self):
        """ Retrieve what the relationship between the user and
        then authenticated user is.

        """
        r = requests.get(
            "https://kippt.com/api/users/%s/relationship" % (self.id),
            headers=self.kippt.header
        )
        return (r.json())

    def follow(self):
        """ Follow a user."

        """
        data = json.dumps({"action": "follow"})
        r = requests.post(
            "https://kippt.com/api/users/%s/relationship" % (self.id),
            headers=self.kippt.header,
            data=data
        )
        return (r.json())

    def unfollow(self):
        """ Unfollow a user."

        """
        data = json.dumps({"action": "unfollow"})
        r = requests.post(
            "https://kippt.com/api/users/%s/relationship" % (self.id),
            headers=self.kippt.header,
            data=data
        )
        return (r.json())
