# -*- coding: utf-8 -*-

from uuid import uuid4

import alfred
import parser
import itemlist
import helpers
import config


def generate_add_feedbackitem(query, info):
	q = info['task']
	tag = info['tag']

	title = "New item '" + ('...' if len(q)==0 else q) + "'"
	subtitle = "Type something to create a new todo"

	if tag is None:
		tag = 'default'
	if tag != 'default':
		subtitle = "Item will be tagged #{0}".format(tag)

	# quick create only works best in default list mode
	quick_create = False
	if len(q) > 0 and tag == 'default':
		config.update_state(command='quick_create', tag='#'+tag, query=query)
		quick_create = True
	else:
		config.update_state(command='', tag='', query='')


	if quick_create:
		return alfred.Item(
			attributes = { 
			'uid' : uuid4(),
			'arg' : '#' + tag + ' ' + q,
			'valid' : 'no',
			'autocomplete' : ''
			},
			title = title,
			subtitle = subtitle,
			icon = "todo_add.png"
		)
	else:
		return alfred.Item(
			attributes = { 
			'uid' : uuid4(),
			'arg' : '#' + tag + ' ' + q,
			'valid' : 'no' if len(q) == 0 else 'yes',
			'autocomplete' : '' if len(q) > 0 else '#' + tag + ' '
			},
			title = title,
			subtitle = subtitle,
			icon = "todo_add.png"
		)

def generate_todo_feedbackitem(t):
	return alfred.Item(
		attributes = { 
		'uid' : uuid4(),
		'arg' : helpers.encode_todo_id(str(t['id']))
		},
		title = t['title'],
		subtitle = helpers.create_subtitle(t),
		icon = helpers.create_icon(t)
	)

def generate_pinned_feedbackitem(t):
	return alfred.Item(
		attributes = { 
		'uid' : uuid4(),
		'arg' : helpers.encode_todo_id(str(t['id']))
		},
		title = t['title'],
		subtitle = helpers.create_subtitle(t),
		icon = "todo_pin.png"
	)

def generate_view(query):
	if len(query) == 0  and config.get('todo.command.last') == 'quick_create':
		add_query = config.get('todo.user.query')
		add_tag = config.get('todo.tag.recent')
		itemlist.save_todo(add_query,silent=True)
		config.update_state(command='', query='')

	info = parser.parse(query)
	tag = info['tag']
	q = info['task']
	
	todos = itemlist.get_todo_list()

	# view for pinned items
	# pinned items should have unique uuid and different logo
	pinned = [t for t in todos if itemlist.feature(t,'pinned') == True]
	pinned = [t for t in pinned if (tag is None or t['group'] == tag)]
	pinned = [t for t in pinned if (q is None or t['title'].lower().find(q.lower()) >= 0)] 
	pinned = pinned[::-1]
	# view for non-pinned items
	normal = [t for t in todos if itemlist.feature(t,'pinned') == False]
	normal = [t for t in normal if (tag is None or t['group'] == tag)]
	normal = [t for t in normal if (q is None or t['title'].lower().find(q.lower()) >= 0)] 
	normal = normal[::-1]

	feedback_items = []
	if len(normal) == 0 and len(pinned) == 0:
		feedback_items.append( generate_add_feedbackitem(query, info) )
	else:
		pinned = map(lambda x: generate_pinned_feedbackitem(x), pinned)
		normal = map(lambda x: generate_todo_feedbackitem(x), normal)
		feedback_items = pinned + normal
	
	alfred.write(alfred.xml(feedback_items))