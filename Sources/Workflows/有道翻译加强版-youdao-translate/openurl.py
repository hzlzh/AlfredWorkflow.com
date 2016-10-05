#coding=utf-8

import sys
import urllib
import webbrowser

param = sys.argv[1].strip()
if len(param) > 4 and param[-4:] == "OPEN":
    arg = urllib.quote(param[:-4])
    webbrowser.open("http://dict.youdao.com/search?le=eng&q="+arg+"&keyfrom=dict.index")

