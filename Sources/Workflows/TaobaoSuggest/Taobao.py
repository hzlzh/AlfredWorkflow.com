#author: Peter Okma
# -*- coding: utf-8 -*-

from Feedback import Feedback
import urllib
import json
import sys
import re

query = sys.argv[1]
#query = '{query}'
url = 'http://suggest.taobao.com/sug?code=utf-8&callback=KISSY.Suggest.callback&q=%s' % query;
f = urllib.urlopen(url);
content = f.read();  ##  KISSY.Suggest.callback({"result": [["arduino套件", "534"], ["arduino 入门套件", "845"], ["arduino uno r3", "120853"], ["arduino 小车", "464"], ["arduino mega2560", "217"], ["arduino wifi", "1272843"], ["arduino leonardo", "53"], ["arduino nano", "177"], ["arduino 蓝牙", "169"], ["arduino 摄像头", "23"]]})

content = content.replace("\s*","")
p = re.compile( r'KISSY.Suggest.callback\((.*)\)')
content = p.sub(r'\1', content);

response = json.loads(content)
#print response;

fb = Feedback()
try:
	
	for title,id in response['result']:
	    #url = 's.taobao.com/search?q=%s&searcy_type=item&s_from=newHeader&source=&ssid=s5-e&search=y' % title
	    #url.replace(' ', '_')
	    fb.add_item(title,
	        subtitle="Search taobao items on %s" % title,
#	        arg=title.replace(" ", "_"))
	        arg=title)
except SyntaxError as e:
    if ('EOF', 'EOL' in e.msg):
        fb.add_item('...')
    else:
        fb.add_item('SyntaxError', e.msg)
except Exception as e:
        fb.add_item(e.__class__.__name__,
            subtitle=e.message)    
print fb

