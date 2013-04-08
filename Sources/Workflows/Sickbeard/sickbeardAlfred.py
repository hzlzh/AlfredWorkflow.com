import json
import urllib2
import webbrowser
from alp.settings import Settings
from feedback import Feedback

_DEFAULTHOST = "http://localhost:8081"


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
        return get_host() + "/api/" + get_APIKey()
    else:
        print "API key is not defined"


def get_data(method_name):
    req = urllib2.Request(url() + "?cmd=" + method_name)
    req.add_header("Accept", "application/json")
    try:
        res = urllib2.urlopen(req)
    except urllib2.URLError:
        print "Can't connect to Sickbeard"
        raise SystemExit()

    return json.loads(res.read())


def open_browser():
    webbrowser.open(get_host())


def open_showpage(identifier):
    webbrowser.open(get_host() + "/home/displayShow?show=" + identifier)


def isAvailable():
    data = get_data("sb.ping")
    success = data['result']
    if not success == "success":
        print "Sickbeard is not available"
    return success


def get_version():
    if isAvailable():
        data = get_data("sb")['data']
        print "Version: " + data['sb_version']

def ping():
    if isAvailable():
        print "Sickbeard is running!"


def get_shows():
    if isAvailable():
        data = get_data("shows")['data']
        fb = Feedback()
        for key in data.keys():
            show = data[key]
            subtitle_text = "Next episode: " + show['next_ep_airdate']
            if show['status'] == "Ended":
                subtitle_text = "Ended"
            fb.add_item(show['show_name'], subtitle_text, key)
        print fb


def get_soon_episodes():
    if isAvailable():
        data = get_data("future&type=soon")['data']['soon']
        fb = Feedback()
        for episode in data:
            episode_name = episode['ep_name']
            show_name = episode['show_name']
            airs = episode['airs']
            air_date = episode['airdate']
            full_title = show_name + " - " + episode_name
            full_subtitle = airs + " (" + air_date + ")"
            fb.add_item(full_title, full_subtitle)
        print fb


def get_history():
    if isAvailable():
        data = get_data("history&limit=10&type=downloaded")['data']
        fb = Feedback()
        for item in data:
            resource = item['resource']
            date = item['date']
            fb.add_item(resource, date, resource)
        print fb


def forced_search():
    if isAvailable():
        data = get_data("sb.forcesearch")
        message = data['message']
        if message:
            print message
        else:
            print "Error - Can't search right now"


def add_show(identifer):
    if isAvailable():
        data = get_data("show.addnew&tvdbid=" + identifer)
        print data['message']


def search_shows(query):
    if isAvailable():
        results = get_data("sb.searchtvdb&name=" + query)['data']['results']
        fb = Feedback()
        for result in results:
            show_name = result['name']
            first_aired = "First aired: " + str(result['first_aired'])
            tvdbid = str(result['tvdbid'])
            fb.add_item(show_name, first_aired, tvdbid)
        print fb


def restart():
    if isAvailable():
        data = get_data("sb.restart")
        print data['message']


def shutdown():
    if isAvailable():
        result = get_data("sb.shutdown")
        print result['message']
