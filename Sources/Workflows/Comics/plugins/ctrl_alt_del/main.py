def enabled():
	return True

def title():
	return "Ctrl+Alt+Del"

def subtitle():
	return "View the latest Ctrl+Alt+Del strip"

def run():
	import os
	import re
	content = os.popen("""curl -s http://www.cad-comic.com/cad/""").read().rstrip()
	strip = re.match(r'.*?src="(http://v.cdn.cad-comic.com/comics/cad.*?)"' , content, re.IGNORECASE|re.S).groups(0)[0]
	os.system('curl -s ' + strip + ' --O strip.png')
	os.system('qlmanage -p strip.png')
