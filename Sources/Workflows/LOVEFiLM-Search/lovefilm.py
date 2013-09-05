import alfred
import json
import urllib



lovefilm, query = alfred.args()

url = u'http://www.lovefilm.{lovefilm}/ajax/autocomplete.html?term={query}&category=all_titles'.format( lovefilm=str(lovefilm), query=str(query))
prefix = u'http://www.lovefilm.{lovefilm}'.format(lovefilm=lovefilm)
json_result = json.load(urllib.urlopen(url))
results = []
if len(json_result["items"]) == 0:
	results.append(alfred.Item(
                               attributes= {'uid': 'nothing-found', 'arg': ''},
                               title=u'Nothing found',
                               subtitle=u'Please try again!',
                               icon=('icon.png')))
for item in json_result["items"]:
    results.append(alfred.Item(
                               attributes= {'uid': item["name"], 'arg': prefix+item["url"]},
                               title=item["name"],
                               subtitle=u'view movie on LOVEFiLM',
                               icon=('icon.png')))
xml = alfred.xml(results)
alfred.write(xml)