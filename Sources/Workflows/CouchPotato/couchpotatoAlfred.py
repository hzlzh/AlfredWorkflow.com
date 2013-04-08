import json
import urllib2
import webbrowser
from alp.settings import Settings
from feedback import Feedback

_DEFAULTHOST = "http://localhost:5050"


def set_APIKey(key):
    Settings().set(apikey=key.strip())


def get_APIKey():
    return Settings().get("apikey")


def set_host(url):
    Settings().set(host=url.strip().rstrip("/"))


def get_host():
    return Settings().get("host", _DEFAULTHOST)


def url():
    if get_APIKey():
        return get_host() + "/api/" + get_APIKey() + "/"
    else:
        print "API key is not defined"


def get_data(method_name):
    req = urllib2.Request(url() + method_name)
    req.add_header("Accept", "application/json")
    try:
        res = urllib2.urlopen(req)
    except urllib2.URLError:
        print "Can't connect to CouchPotato"
        raise SystemExit()

    return json.loads(res.read())


def open_browser():
    webbrowser.open(get_host())


def isAvailable():
    data = get_data("app.available")
    success = data['success']
    if not success:
        print "CouchPotato is not available"
    return success


def get_version():
    if isAvailable():
        data = get_data("app.version")
        print data['version']

def ping():
    if isAvailable():
        print "CouchPotato is running!"


def add_movie_by_id(identifier):
    data = get_data("movie.add?identifier=" + identifier)

    added = data['added']
    if added:
        print "Movie added to wanted list"
    else:
        print "Movie not found!"

def search_movie(query):
    data = get_data("movie.search" + "?q=" + query)
    fb = Feedback()
    for movie in data['movies']:
        movieTitle = movie['titles'][0]
        movieYear = str(movie['year'])
        identifier = movie['imdb']
        fb.add_item(movieTitle, movieYear, identifier)
    print fb


def forced_search():
    if isAvailable():
        data = get_data("searcher.full_search")
        success = data['success']
        if success:
            print "Searching for movies..."
        else:
            print "Error - Can't search right now"


def update():
    if isAvailable():
        data = get_data("updater.check")
        update_avail = data['update_available']
        if update_avail:
            print "Update available - Updating.."
        else:
            print "No update available"


def restart():
    if isAvailable():
        data = get_data("app.restart")
        message = data['restart']
        if message:
            print message.title()
        else:
            print "Error - Can't restart right now"


def shutdown():
    if isAvailable():
        get_data("app.shutdown")
        print "CouchPotato is shutting down"
