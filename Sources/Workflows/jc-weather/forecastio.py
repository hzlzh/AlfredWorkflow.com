#!/usr/bin/env python

'''
Get weather data from Forecast.io
'''

import datetime
import requests
import time

URL_TEMPLATE = 'http://forecast.io/#/f'
API_TEMPLATE = 'https://api.forecast.io/forecast/{}'
api = None


class WeatherException(Exception):
    def __init__(self, message, error=None):
        super(WeatherException, self).__init__(message)
        self.error = error


def set_key(api_key):
    global api
    api = API_TEMPLATE.format(api_key)


def get_forecast_url(location, date=None):
    url = '{}/{}'.format(URL_TEMPLATE, location)
    if date:
        if isinstance(date, (str, unicode)):
            date = datetime.datetime.strptime(date, '%Y-%m-%d').date()
        tstamp = int(time.mktime(date.timetuple()))
        url = '{}/{}'.format(url, tstamp)
    return url


def forecast(location, params=None):
    '''
    Get a forecast for a location

    The location must be lat,lng (e.g., -38.5,85.234)
    '''
    url = '{}/{}'.format(api, location)
    headers = {'Accept-Encoding': 'gzip'}
    r = requests.get(url, params=params, headers=headers)

    if r.status_code != 200:
        raise WeatherException('Your key is invalid or forecast.io is down')

    r = r.json()
    if 'error' in r:
        raise WeatherException('Error getting weather: {}'.format(r['error']),
                               r['error'])

    return r


if __name__ == '__main__':
    from argparse import ArgumentParser
    parser = ArgumentParser()
    parser.add_argument('key', help='API key')
    parser.add_argument('latitude')
    parser.add_argument('longitude')
    args = parser.parse_args()

    set_key(args.key)

    from pprint import pformat
    print pformat(forecast(args.latitude, args.longitude))
