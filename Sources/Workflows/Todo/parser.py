# -*- coding: utf-8 -*-

import re
from pprint import pprint
import sys


def parse(text):
	tag = None
	task = text
	m = re.match(r'#(?P<tag>[^ ]+)$', text, re.IGNORECASE)
	if m is not None:
		tag = m.group('tag')
		task = ""
	else:
		m = re.match(r'#(?P<tag>[^ ]+?) ', text, re.IGNORECASE)
		if m is not None:
			tag = m.group('tag')
			task = text.replace('#' + tag + ' ', "")
		else:
			m = re.match(r'.*? #(?P<tag>[^# ]+?)$', text, re.IGNORECASE)
			if m is not None:
				tag = m.group('tag')
				task = text.replace(' #' + tag, "")
	return {
		'tag' : tag,
		'task': task,
		'rating' : None,
		'pinned' : False
	}


def showparse():
	pprint(parse(sys.argv[1]))


if __name__ == "__main__":
    showparse()