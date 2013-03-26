import sys
import os
import alfred
import json
import urllib2
import urllib

## http://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=wikipedia&srprop=timestamp&format=json
def search_for(lang, query):
    args = {'action': 'query', 'list': 'search', 'srsearch': query, "srprop": "timestamp", 'format': 'json'}
    w_api = "http://" + lang + ".wikipedia.org/w/api.php?" + urllib.urlencode(args)
    response = urllib2.urlopen(w_api)
    data = json.load(response)   
    return data['query']['search']


def parse(lang, item):    
    item_arg = u'http://' + lang + '.wikipedia.org/wiki/' + urllib.quote(item['title'].encode("utf8"))

    return alfred.Item(
        attributes = { 
            'uid' : alfred.uid(item['title']),
            'arg' : item_arg,
            'autocomplete' : item['title']
        },
        title = item['title'],
        subtitle = 'Read about ' + item['title'] + ' on ' + lang + '.wikipedia.org',
        icon = 'icon.png'
    )

# http://en.wikipedia.org/w/api.php?format=json&action=opensearch&search=mull&namespace=0&suggest=
def opensearch_for(lang, query):
    args = {'format': 'json', 'action': 'opensearch', 'search': query, "namespace": "0", 'suggest': ''}
    w_api = "http://" + lang + ".wikipedia.org/w/api.php?" + urllib.urlencode(args)
    response = urllib2.urlopen(w_api)
    data = json.load(response)   
    return data[1]

def opensearch_parse(lang, item):
    item_arg = u'http://' + lang + '.wikipedia.org/wiki/' + urllib.quote(item.encode("utf8"))

    return alfred.Item(
        attributes = { 
            'uid' : alfred.uid(item),
            'arg' : item_arg,
            'autocomplete' : item
        },
        title = item,
        subtitle = 'Read about ' + item + ' on ' + lang + '.wikipedia.org',
        icon = 'icon.png'
    )

def default():
    return alfred.Item(
        attributes = { 
            'uid' : alfred.uid("language"),
            'arg' : ''
        },
        title = 'Enter a language code followed by the search term',
        subtitle = 'e.g. "w en workflow" to search for workflows',
        icon = 'icon.png'
    )

def noresults(query):
    return alfred.Item(
        attributes = { 
            'uid' : alfred.uid("google"),
            'arg' : 'http://google.com/search?q=' + urllib.quote(query.encode("utf8"))
        },
        title = "Search Google for '" + query + "'",
        subtitle = '',
        icon = 'google.png'
    )

def wSearch():
    if len(sys.argv) <= 2:
        alfred.write(alfred.xml([default()]))
        return

    (lang, query) = alfred.args2()
    
    feedback_items = map(lambda x: parse(lang, x), search_for(lang, query))

    # opensearch is used to autocomplete, which means
    # it searches based on the starting of the text that entered
    # feedback_items = map(lambda x: opensearch_parse(lang, x), opensearch_for(lang, query))

    if(len(feedback_items) == 0):
        alfred.write(alfred.xml([noresults(query)]))
        return


    xml = alfred.xml(feedback_items);
    alfred.write(xml)

    
if __name__ == "__main__":
    wSearch()
