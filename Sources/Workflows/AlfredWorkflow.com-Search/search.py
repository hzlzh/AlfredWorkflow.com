# -*- coding: utf-8 -*-

import alfred
from bs4 import BeautifulSoup
import urllib2
import sys
import unicodedata

def decode(s):
    return unicodedata.normalize('NFC', s.decode('utf-8'))

def set_cache():
    html = urllib2.urlopen('http://www.alfredworkflow.com').read()
    soup = BeautifulSoup(html)
    cache = []
    for tr in soup.find_all('tr'):
        if tr.get('id'):
            tds = tr.find_all('td')
            cache.append(
                {
                    'name': tr.get('id'),
                    'description': tds[1].text.replace(tds[1].a.text,'').strip(),
                    'author': tds[2].text.strip(),
                    'download': tds[4].find('a').get('href').strip(),
                    'release': tds[3].find('a').get('href'),
                    'version': tds[0].find('a').get('title')
                }
            )
    alfred.cache.set('workflow.list', cache, expire=600)

def get_cache():
    if alfred.cache.timeout('workflow.list') == -1:
        set_cache()
    return alfred.cache.get('workflow.list')

def filter(w, query):
    return (
            len(query)==0 or
            w['name'].lower().find(query.lower()) >= 0 or
            w['description'].lower().find(query.lower()) >= 0 or
            w['author'].lower().find(query.lower()) >= 0
        )


def search(query):
    workflows = get_cache()
    workflows = [w for w in workflows if filter(w, query)==True]
    feedback = alfred.Feedback()
    for w in workflows:
        feedback.addItem(
            title=w['name'],
            subtitle=w['version'] + w['author'] + ', ' + w['description'],
            arg=w['download']
        )
    feedback.output()

if __name__ == '__main__':
    search(decode(sys.argv[1]))
