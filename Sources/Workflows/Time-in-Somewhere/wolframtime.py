import urllib
import sys
import re

place = sys.argv[1]
appID = 'WHARE2-WAGAJRG3AV'
API_URL = ('http://api.wolframalpha.com/v2/query?input=time%20in%20'
           + place + '&appid=' + appID)
plaintext_tag = '<plaintext>'
plaintext_close_tag = '</plaintext>'

plaintext_lines = []
for line in urllib.urlopen(API_URL).readlines():
    line = line.strip()
    if line[:len(plaintext_tag)] == plaintext_tag:
            plaintext_lines.append(line)

try:
    time_and_date = re.match(plaintext_tag + '(.+)' +
                         plaintext_close_tag, plaintext_lines[1])
    pattern = re.match('(.+)\s+\|\s+(.+)', time_and_date.groups()[0])
except:
    print 'Cannot find time in', place

time = pattern.groups()[0][:-1]
date = pattern.groups()[1]

print 'In', place, 'it is', time, 'on', date 
