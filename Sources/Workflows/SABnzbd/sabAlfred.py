import json
import urllib2
import webbrowser
from alp.settings import Settings
from feedback import Feedback

_DEFAULTHOST = "http://localhost:8080"


def set_APIKey(key):
    Settings().set(apikey=key.strip())
    print "API key changed!"


def get_APIKey():
    return Settings().get("apikey")


def set_host(url):
    Settings().set(host=url.strip().rstrip("/"))
    print "Host URL changed!"


def get_host():
    return Settings().get("host", _DEFAULTHOST)


def url(mode):
    if get_APIKey():
        return get_host() + "/sabnzbd/api?mode=" + mode + "&output=json&apikey=" + get_APIKey()
    else:
        print "API key is not defined"


def get_data(mode):
    req = urllib2.Request(url(mode))
    try:
        res = urllib2.urlopen(req)
    except urllib2.URLError:
        print "Can't connect to SABnzbd"
        raise SystemExit()

    return json.loads(res.read())


def open_browser():
    webbrowser.open(get_host())


def get_jobs():
    data = get_data("qstatus")
    fb = Feedback()
    if len(data['jobs']) > 0:
        for job in data['jobs']:
            filename = job['filename']
            mb_left = job['mbleft']
            mb_total = job['mb']
            subtitle_text = mb_left + " / " + mb_total
            fb.add_item(filename, subtitle_text)
    else:
        fb.add_item("No current jobs")
    print fb


def get_history():
    data = get_data("history")['history']
    fb = Feedback()
    if len(data['slots']) > 0:
        for slot in data['slots']:
            name = slot['name']
            size = slot['size']
            status = slot['status']
            fail_message = slot['fail_message']
            subtitle_text = size + " | " + status + " | " + fail_message
            fb.add_item(name, subtitle_text)
    else:
        fb.add_item("History is empty")
    print fb


def set_max_speed(value):
    data = get_data("config&name=speedlimit&value=" + value)
    if data['status']:
        print "Max download speed changed"


def add_nzb(url):
    data = get_data("addurl&name=" + url)
    if data['status']:
        print "NZB added!"
    else:
        print "NZB failed to be added"


def get_version():
    data = get_data("version")
    print "Version: " + data['version']


def restart():
    get_data("restart")
    print "SABnzbd is restarting"


def shutdown():
    get_data("shutdown")
    print "SABnzbd is shutting down"