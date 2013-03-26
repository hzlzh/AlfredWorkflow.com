#!/usr/bin/python
# -*- coding: utf-8 -*-
from __future__ import division, absolute_import

import alp
import re

url = "http://wapp.baidu.com/f?kw=steam"
r = alp.Request(url, payload=None, post=False).souper()

result = [u'<?xml version="1.0"?>', u'<items>']

i=0
for link in r.find_all("div", "i"):
  title = link.find("a").string.encode('utf-8')
  # print title
  title = re.sub(r"^\d*\. *","",title)
  id = re.search("kz\=(\d*)\&",link.find("a")["href"]).group(1)
  aurl = u"http://tieba.baidu.com/p/" + id
  result.append(u'<item uid="baidusearch' + str(i) + u'" arg="' + aurl + u'">');
  result.append(u'<title>' + title.decode("utf8") + u'</title>')
  result.append(u'<subtitle>打开这帖</subtitle>')
  result.append(u'<icon>icon.png</icon>')
  result.append(u'</item>')  
  i+=1

result.append(u'</items>')
xml = ''.join(result)

print xml.encode("utf8")