def enabled():
	return True

def title():
	return "Penny Arcade"

def subtitle():
	return "View the latest Penny Arcade strip"

def run():
	import os
	strip = os.popen("""curl -s http://penny-arcade.com/comic | grep "http://art.penny-arcade.com" | awk -F\\" '{print $2}'""").read().rstrip()
	os.system('curl -s ' + strip + ' --O strip.jpg')
	os.system('qlmanage -p strip.jpg')
