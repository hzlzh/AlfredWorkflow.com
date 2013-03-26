# -*- coding: utf-8 -*-

import sys
import config
from collections import defaultdict
import itemlist
import alfred
from uuid import uuid4


def export_txt(_tag=None):
	todos = itemlist.get_todo_list()
	tags = defaultdict(list)
	for i in todos: 
		tags[i['group']].append(
			{	'title' : i['title'],
				'created': i['created'],
				'pinned' : itemlist.feature(i,'pinned'),
				'rating' : itemlist.feature(i,'rating')
			}
		)
	for tag in tags:
		if _tag is None or tag==_tag:
			print '#' + tag
			pinned = [t for t in tags[tag] if t['pinned']]
			normal = [t for t in tags[tag] if not t['pinned']]
			for todo in pinned:
				print todo['title'] + ' [pinned]'
			for todo in normal:
				print todo['title']
			print " "

def export_yaml():
	todoPath = config.get('todo.db')
	with open(todoPath, 'r') as fin:
		print fin.read()


def generate_feedbackitem(t):
	return alfred.Item(
		attributes = { 
		'uid' : uuid4(),
		'arg' : t['arg']
		},
		title = t['title'],
		subtitle = t['subtitle'],
		icon = t['icon']
	)

def generate_noitems():
	return alfred.Item(
		attributes = { 
		'uid' : uuid4(),
		'arg' : '',
		'valid' : 'no'
		},
		title = "Your todo list is empty",
		subtitle = 'You need to create some items first to export',
		icon = "todo_export.png"
	)

def generate_export_view():
	feedback_items = []
	todos = itemlist.get_todo_list()
	if len(todos) == 0:
		feedback_items.append(generate_noitems())
	else:
		items = []
		items.append({'title':'Export all items as plain text', 'subtitle':'Will be copied to your clipboard', 'arg':'txt', 'icon':'export_txt.png'})
		todos = itemlist.get_todo_list()
		tags = defaultdict(list)
		for i in todos: tags[i['group']].append(1)
		for tag in tags:
			if tag != 'default':
				items.append({'title':'Export #' + tag, 'subtitle':'Will be copied to your clipboard', 'arg':'txt ' + tag, 'icon':'export_txt.png'})		
		feedback_items = map(lambda x: generate_feedbackitem(x), items)
	alfred.write(alfred.xml(feedback_items))

def main():

	if len(sys.argv) == 1:
		generate_export_view()
	else: 
		format = sys.argv[1]
		tag = None
		if len(sys.argv) == 3:
			tag = sys.argv[2]
		if format == "txt":
			export_txt(_tag=tag)
		if format == "yaml":
			export_yaml()


if __name__ == "__main__":
    main()