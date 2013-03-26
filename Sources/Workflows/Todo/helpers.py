from datetime import datetime
import re
import os

def create_subtitle(t):
	created = t['created']
	rightnow = datetime.now()
	d = rightnow - created
	(days, hours, minutes) = (d.days, d.seconds//3600, (d.seconds//60)%60)
	all_seconds = d.total_seconds()
	subtitle = None
	if all_seconds <= 60:
		subtitle = "added moments ago"
	elif all_seconds <= 120:
		subtitle = "added 1 minute ago"
	elif all_seconds <= 3600:
		subtitle = "added {0} minutes ago".format(minutes)
	elif all_seconds <= 7200:
		subtitle = "added about an hour ago"
	elif all_seconds <= 86400:
		subtitle = "added {0} hours ago".format(hours)
	if subtitle is None:
		if days == 1:
			subtitle = "added yesterday"
		elif days < 7:
			subtitle = "added this week"
		elif days < 14:
			subtitle = "added last week"
		elif days < 30:
			subtitle = "added {0} weeks ago".format(int(days/7))
		elif days < 365:
			subtitle = "added about {0} month{1} ago".format(int(days/30), "s" if days/30 > 1 else "")
		else:
			subtitle = "added before last year"

	if t['group'] != "default":
		subtitle = "#{0} {1}".format(t['group'], subtitle)

	return subtitle


def create_icon(t):
	return ("icon.png" if getDays(t['created']) <= 5 else "todo_old.png")

def getDays(created):
	rightnow = datetime.now()
	d = rightnow - created
	return d.days

def macSetClipboard(text):
    outf = os.popen('pbcopy', 'w')
    outf.write(text)
    outf.close()

def is_todo(q):
	return q.startswith("___id___:")

def is_tag(q):
	return q.startswith("___tag___:")

def extract_tag(q):
	return q.replace("___tag___:","")

def extract_todo_id(q):
	return q.replace("___id___:","")

def encode_tag(q):
	return "___tag___:" + q

def encode_todo_id(q):
	return "___id___:" + q

