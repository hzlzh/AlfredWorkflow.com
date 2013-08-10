
from alp.settings import Settings
from feedback import Feedback
import subprocess
import sys
import re

_defaultDepth = '32'

def get_resolution():
	try:
		res = subprocess.Popen('./cscreen', shell=True, stdout=subprocess.PIPE)
		res.stdout.readline() #skip headers
		cur = res.stdout.readline()
		matches = re.search('[a-zA-z0-9]+ +\d+ +\d+ +(\d+) +(\d+) +\d+', cur)
		if matches:
			return (int(matches.group(1)),int(matches.group(2)))

		print 'Cannot Find Resolution'
		raise SystemExit()

	except OSError as e:
		print  str(e)
		raise SystemExit()

def get_options():
	try:
		res = subprocess.Popen('./cscreen -v', shell=True, stdout=subprocess.PIPE)
		res.stdout.readline() #skip headers
		resolutions = []
		for cur in iter(res.stdout):
			matches = re.search('[a-zA-z0-9]+ +\d+ +(\d+) +(\d+) +(\d+) +\d+', cur)
			if not matches:
				break
			if matches.group(1) == _defaultDepth:
				resolutions.append((int(matches.group(2)), int(matches.group(3))))
		resolutions.sort()
		return resolutions

	except OSError as e:
		print  str(e)
		raise SystemExit()

def set_resolution(res):
	try:
		subprocess.Popen('./cscreen -x ' + str(res[0]) + ' -y ' + str(res[1]), shell=True, stdout=subprocess.PIPE)
		print 'Resolution set to ' + str(res[0]) + 'X' + str(res[1])
	except OSError as e:
		print  str(e)

def res_up():
	options = get_options()
	cur = get_resolution()
	ind = None
	for idx, res in enumerate(options):
		if res[0] == cur[0] and res[1] == cur[1]:
			ind = idx
			break

	if ind == None:
		print 'Current resolution not in list'
		raise SystemExit()
	elif ind >= len(options) - 1:
		print 'Current resolution is at maximum';
		raise SystemExit()
	else:
		set_resolution(options[ind + 1])

def res_down():
	options = get_options()
	cur = get_resolution()
	ind = None
	for idx, res in enumerate(options):
		if res[0] == cur[0] and res[1] == cur[1]:
			ind = idx
			break

	if ind == None:
		print 'Current resolution not in list'
		raise SystemExit()
	elif ind == 0:
		print 'Current resolution is at minimum';
		raise SystemExit()
	else:
		set_resolution(options[ind - 1])

def show_options(arg):
	fb = Feedback()

	options = get_options()
	cur = get_resolution()
	for idx, option in enumerate(options):
		display = str(option[0]) + 'X' + str(option[1])
		val = '(' + str(option[0]) + ',' + str(option[1]) + ')'
		if cur[0] == option[0] and cur[1] == option[1]:
			sub = '**Current Resolution'
			valid = 'no'
		else:
			sub = 'Set Resolution'
			valid = 'yes'

		if arg == '' or arg in str(option[0]) or arg in str(option[1]):
			fb.add_item(display, sub, val, valid)

	print fb
