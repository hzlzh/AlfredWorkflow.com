'''
Shorten URL v1.1

Github: https://github.com/hzlzh/Alfred-Workflows
Author: hzlzh (hzlzh.dev@gmail.com)
Twitter: @hzlzh
Blog: https://zlz.im/Alfred-Workflows/
'''
from feedback import Feedback

import urllib
import urllib2
import json
import sys

query = sys.argv[1]

api = {
'goo.gl' : {'api_url':'https://www.googleapis.com/urlshortener/v1/url','title':'goo.gl','des':'http://goo.gl/'},
'bit.ly' : {'api_url':'https://api-ssl.bitly.com/v3/shorten?format=json&login=hzlzh&apiKey=R_e8bcc43adaa5f818cc5d8a544a17d27d&longUrl=','title':'bit.ly','des':'http://bit.ly/'},
't.cn' : {'api_url':'https://api.weibo.com/2/short_url/shorten.json?access_token=2.00WSLtpB0GRHJ9745670860ceNWWiC&url_long=','title':'t.cn','des':'http://t.cn/'},
'j.mp' : {'api_url':'http://api.j.mp/v3//shorten?format=json&login=hzlzh&apiKey=R_e8bcc43adaa5f818cc5d8a544a17d27d&longUrl=','title':'j.mp','des':'http://j.mp/'},
'is.gd' : {'api_url':'http://is.gd/create.php?format=json&url=','title':'is.gd','des':'http://is.gd/'},
'v.gd' : {'api_url':'http://v.gd/create.php?format=json&url=','title':'v.gd','des':'http://v.gd/'}
}

fb = Feedback()
for title in api:
    fb.add_item(api[title]['title'],
        subtitle="Using %s" % api[title]['des'],
        arg='{"type":"'+title+'","api_url":"'+api[title]['api_url']+'","long_url":"'+query+'"}',icon='favicons/'+title+'.png')
print fb
