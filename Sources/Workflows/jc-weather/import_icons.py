#!/usr/bin/env python


'''
Convert a weather icon set for whatever uses these standard numbers to a
Weather Underground-compatible icon set.

Additional, 'wind' is included for forecast.io.
'''

import os.path
from os import system
from argparse import ArgumentParser

MAPPING = {
    'chanceflurries': '13',
    'chancerain': '39',
    'chancesleet': '7',
    'chancesnow': '41',
    'chancetstorms': '37',
    'clear': '32',
    'cloudy': '30',
    'flurries': '13',
    'fog': '20',
    'hazy': '21',
    'mostlycloudy': '28',
    'mostlysunny': '34',
    'partlycloudy': '30',
    'partlysunny': '30',
    'rain': '12',
    'sleet': '6',
    'snow': '14',
    'sunny': '32',
    'tstorms': '0',
    'wind': '23',
    'nt_chanceflurries': '46',
    'nt_chancerain': '45',
    'nt_chancesleet': '46',
    'nt_chancesnow': '46',
    'nt_chancetstorms': '47',
    'nt_clear': '31',
    'nt_cloudy': '27',
    'nt_mostlycloudy': '27',
    'nt_mostlysunny': '33',
    'nt_partlycloudy': '29',
    'nt_partlysunny': '29',
    'nt_sunny': '31',
    'nt_tstorms': '17',
}


parser = ArgumentParser()
parser.add_argument('source', help='Source directory')
parser.add_argument('dest', help='Destination directory')
args = parser.parse_args()

for name in MAPPING.keys():
    source = os.path.join(args.source, '{}.png'.format(MAPPING[name]))
    dest = os.path.join(args.dest, '{}.png'.format(name))
    system("cp '{}' '{}'".format(source, dest))
