# -*- coding: utf-8 -*-

import sys
import json
from urllib2 import urlopen
from urllib import urlencode, quote
import codecs
import os
import alfred
from uuid import uuid4
import re
import subprocess

def item(arg='', autocomplete='', valid='yes', title='', subtitle='',icon='icon.png'):
    return alfred.Item(
        attributes={
            'uid': uuid4(),
            'arg': arg,
            'autocomplete': autocomplete,
            'valid': valid
        },
        title=title,
        subtitle=subtitle,
        icon=icon
    )


def get_api_key():
    return "3qZPXLTn"


def _routes(r):
    return r['routes']


def _segments(r):
    return r['segments']


def _stops(r):
    return r['stops']


def _agencies(r):
    return r['agencies']


def get_agency_name(r, code):
    agencies = _agencies(r)
    for agency in agencies:
        if agency.get('code', '') == code:
            return agency.get('name', code)
    return code


def generate_map(path, spos, tpos, path_encoded=True):
    if spos is not None:
        markerA = 'label:A|' + spos
        markerA = 'markers=' + quote(markerA)

    if tpos is not None:
        markerB = 'label:B|' + tpos
        markerB = 'markers=' + quote(markerB)

    if path:
        args = {'size': '640x640', 'sensor': 'false', 'path': 'color:0xff0000ff|weight:5|' + ('enc:' if path_encoded else '') + path}
        api = "http://maps.googleapis.com/maps/api/staticmap?" + urlencode(args)
        if spos is not None:
            api = api + '&' + markerA
        if tpos is not None:
            api = api + '&' + markerB
    else:
        args = {'size': '640x640', 'sensor': 'false'}
        api = "http://maps.googleapis.com/maps/api/staticmap?" + urlencode(args)
        if spos is not None:
            api = api + '&' + markerA
        if tpos is not None:
            api = api + '&' + markerB
    if len(api) > 2048:
        args = {'size': '640x640', 'sensor': 'false'}
        api = "http://maps.googleapis.com/maps/api/staticmap?" + urlencode(args)
        if spos is not None:
            api = api + '&' + markerA
        if tpos is not None:
            api = api + '&' + markerB
    return api if len(api) <= 2048 else None


def get_duration(d, prominent=False):
    if d < 60:
        return str(d) + "min"
    if d == 60:
        return "1hr"
    h, m = divmod(d, 60)
    if prominent:
        if m > 30:
            h += 1
        return "{0}hr".format(h)
    if m == 0:
        return "{0}hr".format(h)
    return "{0}hr {1}min".format(h, m)


def get_frequency(f):
    per_day = f/7.0
    if per_day <= 24:
        return '{0} times per day'.format(int(per_day))
    per_hour = per_day/24.0
    if per_hour == 1.0:
        return "hourly"
    return 'every {0}min'.format(int(60/per_hour))


def get_distance(d):
    if d == 0:
        return ''
    return str(int(round(d)))+'km'


def do_search(origin, destination):
    args = {'key': get_api_key(), 'oName': origin, 'dName': destination}
    api = "http://evaluate.rome2rio.com/api/1.2/json/Search?" + urlencode(args)
    # print api
    try:
        data = json.load(urlopen(api))
        data['userquery'] = {'origin': origin,'destination':destination}
        with codecs.open('search.json', "w", "utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=1)
        success = True
    except:
        success = False
    return success


def load_search():
    if not os.path.exists('search.json'):
        return None
    try:
        with open('search.json', 'r') as f:
            data = json.load(f)
    except:
        data = None
    return data


def reset():
    if os.path.exists('search.json'):
        os.remove('search.json')


def display_route(result, ri_1, items):
    if result == None:
        items.append(item(title='No routes found'))
        return

    routes = _routes(result)
    routes_count = len(routes)
    ri = ri_1 - 1
    if ri >= routes_count or routes_count == 0:
        items.append(item(title='No routes found'))
        return

    route = routes[ri]
    next_route = ri_1 + 1
    if next_route > routes_count:
        next_route = 1

    stops = _stops(route)
    segments = _segments(route)

    total_duration = get_duration(route['duration'], prominent=True)
    total_distance = get_distance(route['distance'])

    items.append(item(
        title=route['name'],
        subtitle='{0} of {1} - approx. {2}'.format(ri_1, routes_count, total_duration),
        autocomplete='route {0}'.format(next_route),
        arg='http://www.rome2rio.com/s/'+quote(result['userquery']['origin'].encode('utf-8'))+'/'+quote(result['userquery']['destination'].encode('utf-8'))
    ))

    total_stops = len(stops)
    total_segments = len(segments)
    for si, stop in enumerate(stops):
        name = stop['name']
        kind = '' if stop.get('kind', None) != 'airport' else ('airport (' + stop['code'] + ')')
        title = name + ' ' + kind  # only for airports
        subtitle = ''
        icon = 'icon.png'
        if si < total_segments:
            segment = segments[si]
            kind = segment['kind']
            map_path = segment.get('path', None)
            if kind == 'train' or kind == 'bus' or kind == 'ferry':
                # check if have a train journey with legs and hops
                legs = segment['itineraries'][0]['legs']
                for li, leg in enumerate(legs):
                    for hi, hop in enumerate(leg['hops']):
                        # If this is the very first stop, don't overwrite the
                        # hop's starting name
                        if si == 0 and li == 0 and hi == 0:
                            if title.strip() != hop['sName'].strip():
                                title = title.strip() + ' - ' + hop['sName'].strip()
                        else:
                            title = hop['sName']
                        duration = get_duration(hop['duration'])
                        frequency = get_frequency(hop['frequency'])
                        map_link = generate_map(map_path, hop['sPos'], hop['tPos'])

                        # find which line is available
                        if kind == 'train':
                            for line_i, line in enumerate(hop['lines']):
                                line_info = line.get('vehicle', '')
                                name = line.get('name', '')
                                if len(name) > 0:
                                    # e.g. Tube (Bakerloo)
                                    line_info = line_info + ' (' + name + ')'
                                else:
                                    # e.g. National Rail
                                    agency_code = line.get('agency', '')
                                    if len(agency_code) > 0:
                                        line_info = get_agency_name(result, agency_code)
                        elif kind == 'bus' or kind == 'ferry':
                            line_info = []
                            for line_i, line in enumerate(hop['lines']):
                                line_info.append(line.get('name', None))
                            line_info = ','.join(line_info)

                        subtitle = ''.join([duration+' ', line_info, ', ' + frequency])
                        icon = kind+'.png'
                        items.append(item(title=title, subtitle=subtitle, icon=icon, valid='no', arg=map_link))
            else:

                duration = get_duration(segment['duration'])
                distance = get_distance(segment['distance'])

                if kind == 'flight':
                    spos = stop['pos']  # current airport
                    tpos = stops[si+1]['pos']  # next airport
                    map_link = generate_map(spos+'|'+tpos, spos, tpos, path_encoded=False)
                else:
                    map_link = generate_map(map_path, segment.get('sPos', None), segment.get('tPos', None))

                # min kms type
                subtitle = duration + ' ' + distance
                icon = kind + '.png'
                items.append(item(title=title, subtitle=subtitle, icon=icon, valid='no', arg=map_link))
        if si == len(segments):
            # last stop has no segment
            icon = 'final.png'
            map_link = generate_map(None, stop['pos'], None)
            items.append(item(title=title, subtitle=subtitle, icon=icon, valid='no',arg=map_link))


def show_alfred():
    subprocess.call(
        'osascript -e "tell application \\"Alfred 2\\" to search \\"rr \\""',
        shell=True
    )


def google_autocomplete(items, q, origin, origin_input):
    api = "https://maps.googleapis.com/maps/api/place/autocomplete/json?key=AIzaSyC_jgjdZkx5TxaMjuVLRBq_9x8zDxnqsHQ&sensor=false&input=" + quote(q.encode('utf-8'))
    content = urlopen(api, timeout=5).read()
    data = json.loads(content)
    if data['status'] != 'OK':
        return
    for prediction in data['predictions']:
        place = prediction['description']
        if origin:
            autocomplete = place+' to '
        else:
            autocomplete = origin_input+' to '+place
        items.append(item(title=place, subtitle=place, valid='no', autocomplete=autocomplete))


def autocomplete(items, q, origin, origin_input):
    try:
        api = "http://www.rome2rio.com/api/1.2/jsonp/autocomplete?query=" + quote(q.encode('utf-8'))
        content = urlopen(api, timeout=5).read()
        content = content[1:][:-1]
        data = json.loads(content)

        # if len(data['places']) == 1:
        #     return
        for place in data['places']:
            if origin:
                autocomplete = place['longName']+' to '
            else:
                autocomplete = origin_input+' to '+place['longName']
            items.append(item(title=place['shortName'], subtitle=place['longName'], valid='no', autocomplete=autocomplete))

        if len(data['places']) == 0:
            google_autocomplete(items, q, origin, origin_input)
    except:
        pass


def main():
    command, query = sys.argv[1].decode('utf-8'), ' '.join(sys.argv[2:]).decode('utf-8')

    autocomplete_enabled = False
    if command == "--query-autocomplete":
        autocomplete_enabled = True
        command = "--query"

    if command == "--reset":
        reset()
        show_alfred()

    elif command == "--search":
        if query.startswith('http://'):
            subprocess.call(["open", query])
        else:
            query_info = query.split(" to ")
            success = do_search(query_info[0], query_info[1])
            if success:
                show_alfred()
            else:
                print query

    elif command == "--query":
        items = []
        result = load_search()
        if re.match(r'^route \d+$', query):
            display_route(result, int(query.replace('route ', '')), items)
        elif len(query) > 0 and query.find(' to ') < 0:
            origin = query
            items.append(item(title='Find routes', subtitle=origin + u" ➡ ?", arg=query, valid='no', autocomplete=origin))
            if len(query) > 3 and autocomplete_enabled:
                autocomplete(items, origin, origin=True, origin_input=query)
        elif re.match(r'.+? to .*', query):
            query_info = query.split(" to ")
            origin = query_info[0]
            destination = "?" if len(query_info[1]) == 0 else query_info[1]
            items.append(item(title='Find routes', subtitle=origin + u" ➡ " + destination, arg=query, valid='yes' if destination != '?' else 'no'))
            if len(destination) > 3 and autocomplete_enabled:
                autocomplete(items, destination, origin=False, origin_input=origin)
        else:
            if result is not None and len(query) == 0:
                display_route(result, 1, items)
            else:
                items.append(item(title='Type a search query', subtitle='E.g. New York to London', valid='no', autocomplete='New York to London'))
        alfred.write(alfred.xml(items))

if __name__ == '__main__':
    main()
