import requests
import json


class Clips:
    """Clips class

    Handles the clips endpoint of the Kippt API.
    """
    def __init__(self, kippt):
        """ Instantiates a Clips object.

        Parameters:
        kippt - KipptAPI object

        """
        self.kippt = kippt

    def all(self, **args):
        """ Return all Clips.

        """
        limit = args['limit'] if 'limit' in args else 20
        offset = args['offset'] if 'offset' in args else 0

        r = requests.get(
            "https://kippt.com/api/clips?limit=%s&offset=%s" % (limit, offset),
            headers=self.kippt.header
        )
        return (r.json())

    def feed(self, **args):
        """ Return the Clip feed.

        """
        limit = args['limit'] if 'limit' in args else 20
        offset = args['offset'] if 'offset' in args else 0

        r = requests.get(
            "https://kippt.com/api/clips/feed?limit=%s&offset=%s" % (limit, offset),
            headers=self.kippt.header
        )
        return (r.json())

    def favorites(self, **args):
        """ Return favorite clips.

        """
        limit = args['limit'] if 'limit' in args else 20
        offset = args['offset'] if 'offset' in args else 0

        r = requests.get(
            "https://kippt.com/api/clips/favorites?limit=%s&offset=%s" % (limit, offset),
            headers=self.kippt.header
        )
        return (r.json())

    def create(self, url, **args):
        """ Create a new Kippt Clip.

        Parameters:
        - url (Required)
        - args Dictionary of other fields

        Accepted fields can be found here:
            https://github.com/kippt/api-documentation/blob/master/objects/clip.md
        """
        # Merge our url as a parameter and JSONify it.
        data = json.dumps(dict({'url': url}, **args))
        r = requests.post(
            "https://kippt.com/api/clips",
            headers=self.kippt.header,
            data=data
        )
        return (r.json())

    def search(self, query, **args):
        """ Search for a clip.

        Parameters:
        - query String we are searching for.
        """
        limit = args['limit'] if 'limit' in args else 20
        offset = args['offset'] if 'offset' in args else 0

        r = requests.get(
            "https://kippt.com/api/clips/search?q=%s&limit=%s&offset=%s" % (query, limit, offset),
            headers=self.kippt.header
        )
        return (r.json())

    def clip(self, id):
        """ Returns a Clip object.

        """
        return Clip(self.kippt, id)


class Clip:
    """Clip class

    Handles individual clip requests.
    """

    def __init__(self, kippt, id):
        """ Instantiates a clip object given a KipptAPI object, and a clip ID.

        """
        self.kippt = kippt
        self.id = id

    # GET Requests
    def content(self):
        """ Retrieve the Clip object.

        """
        r = requests.get(
            "https://kippt.com/api/clips/%s" % (self.id),
            headers=self.kippt.header
        )
        return (r.json())

    def comments(self, **args):
        """ Retrieve comments on a clip.

        """
        limit = args['limit'] if 'limit' in args else 20
        offset = args['offset'] if 'offset' in args else 0

        r = requests.get(
            "https://kippt.com/api/clips/%s/comments?limit=%s&offset=%s" % (self.id, limit, offset),
            headers=self.kippt.header
        )
        return (r.json())

    def likes(self, **args):
        """ Retrieve likes of a clip.

        """
        limit = args['limit'] if 'limit' in args else 20
        offset = args['offset'] if 'offset' in args else 0

        r = requests.get(
            "https://kippt.com/api/clips/%s/likes?limit=%s&offset=%s" % (self.id, limit, offset),
            headers=self.kippt.header
        )
        return (r.json())

    # PUT & POST Requests
    def update(self, **args):
        """ Updates a Clip.

        Parameters:
        - args Dictionary of other fields

        Accepted fields can be found here:
            https://github.com/kippt/api-documentation/blob/master/objects/clip.md
        """
        # JSONify our data.
        data = json.dumps(args)
        r = requests.put(
            "https://kippt.com/api/clips/%s" % (self.id),
            headers=self.kippt.header,
            data=data)
        return (r.json())

    def like(self):
        """ Like a clip.

        """
        r = requests.post(
            "https://kippt.com/api/clips/%s/likes" % (self.id),
            headers=self.kippt.header
        )
        return (r.json())

    def favorite(self):
        """ Favorite a clip.

        """
        r = requests.post(
            "https://kippt.com/api/clips/%s/favorite" % (self.id),
            headers=self.kippt.header
        )
        return (r.json())

    def comment(self, body):
        """ Comment on a clip.

        Parameters:
        - body (Required)
        """
        # Merge our url as a parameter and JSONify it.
        data = json.dumps({'body': body})
        r = requests.post(
            "https://kippt.com/api/clips/%s/comments" (self.id),
            headers=self.kippt.header,
            data=data
        )
        return (r.json())

    # DELETE Requests
    def delete(self):
        """ Delete a clip.

        """
        r = requests.delete(
            "https://kippt.com/api/clips/%s" (self.id),
            headers=self.kippt.header
        )
        return (r.json())

    def unfavorite(self):
        """ Unfavorite a clip.

        """
        r = requests.delete(
            "https://kippt.com/api/clips/%s/favorite" % (self.id),
            headers=self.kippt.header
        )
        return (r.json())

    def unlike(self):
        """ Unlike a clip.

        """
        r = requests.delete(
            "https://kippt.com/api/clips/%s/likes" % (self.id),
            headers=self.kippt.header)
        return (r.json())

    def uncomment(self, comment_id):
        """ Remove a comment on a clip.

        Parameters:
        - comment_id ID of the comment to be removed.

        """
        r = requests.delete(
            "https://kippt.com/api/clips/%s/comments/%s" % (self.id, comment_id),
            headers=self.kippt.header
        )
        return (r.json())
