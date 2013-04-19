#!/usr/bin/env python

import datetime
import requests

FORECAST_URL = 'http://www.wunderground.com/cgi-bin/findweather/' \
               'getForecast'
API_TEMPLATE = 'http://api.wunderground.com/api/{}'
api = None


class WeatherException(Exception):
    def __init__(self, message, error=None):
        super(WeatherException, self).__init__(message)
        self.error = error


def set_key(key):
    global api
    api = API_TEMPLATE.format(key)


def get_forecast_url(location, date=None):
    url = '{}?query={}'.format(FORECAST_URL, location)
    if date:
        if isinstance(date, (str, unicode)):
            date = datetime.datetime.strptime(date, '%Y-%m-%d').date()
        url += '&hourly=1&yday={}&weekday={}'.format(
            date.strftime('%j'), date.strftime('%A'))
    return url


def forecast(location):
    '''
    Get the current conditions and a 4-day forecast for a location

    The location may be 'latitude,longitude' (-39.452,18.234), a US ZIP code,
    or a 'state/city' path like 'OH/Fairborn' or 'NY/New_York'.
    '''
    url = '{}/conditions/forecast10day/q/{}.json'.format(api, location)
    r = requests.get(url).json()
    if 'error' in r['response']:
        raise WeatherException('Your key is invalid or wunderground is down',
                               r['response']['error'])
    return r


def autocomplete(query):
    '''Return autocomplete values for a query'''
    url = 'http://autocomplete.wunderground.com/aq?query={}'.format(query)
    return requests.get(url).json()['RESULTS']


if __name__ == '__main__':
    from argparse import ArgumentParser
    from pprint import pformat

    parser = ArgumentParser()
    parser.add_argument('function', choices=('forecast', 'autocomplete'))
    parser.add_argument('location', help='ZIP code')
    parser.add_argument('-k', '--key', help='API key')
    args = parser.parse_args()

    if args.key:
        set_key(args.key)

    func = globals()[args.function]
    print pformat(func(args.location))
