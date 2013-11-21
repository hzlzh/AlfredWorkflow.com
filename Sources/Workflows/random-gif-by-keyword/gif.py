import requests
import sys

query = sys.argv[1]
api_key = 'dc6zaTOxFJmzC'
base_url = 'http://api.giphy.com/v1/gifs/screensaver'

def search_giphy_by_tag(tag):
    url = "{base_url}?api_key={api_key}&tag={tag}".format(base_url=base_url, api_key=api_key, tag=query)
    try:
        response = requests.get(url)
        image = response.json()['data']['image_original_url'].strip()
        print image
    except:
        print 'Could not get random GIF'

if __name__ == '__main__':
    search_giphy_by_tag(query)
