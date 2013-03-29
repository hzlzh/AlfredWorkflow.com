import sys
import os
import PyAl

def search_for(query):
    args = {'q': query, 'page_limit': '9', 'page': '1', "apikey": "88c6ww77pac55ybxsn5dmhqp"}
    rt_api = "http://api.rottentomatoes.com/api/public/v1.0/movies.json"
    myScraper = PyAl.Request(rt_api, args)
    theResult = myScraper.request.json

    return theResult['movies']


def makeTitle(item):
    if item['year'] == 0:
        year = 'Upcoming'
    else:
        year = str(item['year'])
    return item['title'] + ' ['+year+']'

def makeSubtitle(item):
    critics_score = item['ratings']['critics_score']
    audience_score = item['ratings']['audience_score']
    if(critics_score <= 0):
        critics = 'Critics: no consensus yet'
        if(audience_score <= 0):
            audience = 'Audience: no consensus yet'
        else:
            audience = 'Audience: ' + str(audience_score) + '% want to see it'  
    else:
        critics = 'Critics: ' + str(critics_score) + '%'
        if(audience_score <= 0):
            audience = 'Audience: no consensus yet'
        else:
            audience = 'Audience: ' + str(audience_score) + '% liked it'  
    return critics + ", " + audience

def makeIcon(item):
    critics_score = item['ratings']['critics_score']
    if(critics_score > 90):
        return "fresh.png"
    elif(critics_score > 50):
        return "good.png"
    elif(critics_score > 0):
        return "rotten.png"
    else:
        return "noidea.png"

def resultParse(item):
    return {
        'uid': item['id'],
        'arg': item['links']['alternate'],
        'title': makeTitle(item),
        'subtitle': makeSubtitle(item),
        'icon': makeIcon(item),
    }


def rtSearch():
    q = sys.argv[1]
    if len(q) < 3:
        return

    items = map(lambda x: resultParse(x), search_for(q))

    feedback = PyAl.Feedback()
    bundleID = PyAl.bundle()
    for anItem in items:
        uid = bundleID + anItem.pop("uid")
        arg = anItem.pop("arg")
        feedback.addItem(argsDict={'uid':uid, 'arg':arg}, itemDict=anItem)

    print feedback


if __name__ == "__main__":
    rtSearch()
