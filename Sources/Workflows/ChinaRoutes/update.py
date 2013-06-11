#!/usr/bin/env python
# -*- coding: UTF-8 -*-
import re
import urllib2
import sys
import argparse
import math
import textwrap

url=r'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest'
data=urllib2.urlopen(url).read()

cnregex=re.compile(r'apnic\|cn\|ipv4\|[0-9\.]+\|[0-9]+\|[0-9]+\|a.*',re.IGNORECASE)
cndata=cnregex.findall(data)

ipfile=open('ip','w')

count = 0
for count,item in enumerate(cndata):
  unit_items=item.split('|')
  starting_ip=unit_items[3]
  num_ip=int(unit_items[4])

  imask=0xffffffff^(num_ip-1)
  #convert to string
  imask=hex(imask)[2:]
  mask=[0]*4
  mask[0]=imask[0:2]
  mask[1]=imask[2:4]
  mask[2]=imask[4:6]
  mask[3]=imask[6:8]

  #convert str to int
  mask=[ int(i,16 ) for i in mask]
  mask="%d.%d.%d.%d"%tuple(mask)

  #mask in *nix format
  mask2=32-int(math.log(num_ip,2))

  ipfile.write('%s/%s\n'%(starting_ip, mask2))
  count += 1

ipfile.close()
print '更新完毕，一共 %d 条数据'%(count)
