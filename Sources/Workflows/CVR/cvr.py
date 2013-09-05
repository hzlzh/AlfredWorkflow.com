import json
import urllib2
import urllib
from feedback import Feedback

_DEFAULTHOST = "https://cvrapi.dk/"


def get_data(cvr="", name=""):
    if cvr:
        req = urllib2.Request(_DEFAULTHOST + cvr)
    elif name:
        req = urllib2.Request(_DEFAULTHOST + "name/" + urllib.quote(name))
    req.add_header("Accept", "application/json")
    req.add_header("User-agent", "CVR-Alfred")
    try:
        res = urllib2.urlopen(req)
        return json.loads(res.read())
    except urllib2.URLError:
        print "Kan ikke oprette forbindelse"
        raise SystemExit()


def parse_data(data, showCVR):
    fb = Feedback()
    address = data['adresse'] + ", " + str(data['postnr']) + " " + data['by']
    name = data['navn']
    phone = ""
    mail = ""
    if showCVR:
        name = data['navn'] + " - " + str(data['cvr'])
    if 'telefon' in data:
            phone = " - Tlf: " + data['telefon']
    if 'email' in data:
        mail = " - Email: " + data['email']
    fb.add_item(name, address + phone + mail, str(data['cvr']))
    return fb


def lookup(query):
    fb = Feedback()
    if len(query) == 8 and query.isdigit():
        data = get_data(query)
        if 'error' in data:
            fb.add_item("Ugyldigt CVR-nummer")
        else:
            fb = parse_data(data, False)
    elif len(query) > 8 and query.isdigit():
        fb.add_item("CVR-nummeret er for langt", "CVR-numre er 8-cifret")
    elif len(query) < 8 and query.isdigit():
        fb.add_item("Indtast CVR-nummer")
    else:
        data = get_data(name=query)
        fb = parse_data(data, True)
    print fb
