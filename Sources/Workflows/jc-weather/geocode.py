#!/usr/bin/env python

'''
Use the Google Geocoding API to lookup the physical location of place names.
'''

import requests

api = 'http://maps.googleapis.com/maps/api/geocode/json'


def lookup(location):
    '''Lookup a location, which can be a ZIP, city, address, etc.'''
    params = {'address': location, 'sensor': 'false'}
    r = requests.get(api, params=params).json()
    if r.get('status') == 'OK':
        results = r['results'][0]
        data = {
            'name': results['formatted_address'],
            'latitude': results['geometry']['location']['lat'],
            'longitude': results['geometry']['location']['lng']
        }
        return data
    raise Exception('Request failed')


if __name__ == '__main__':
    from argparse import ArgumentParser
    parser = ArgumentParser()
    parser.add_argument('location')
    args = parser.parse_args()

    from pprint import pformat
    print pformat(lookup(args.location))
