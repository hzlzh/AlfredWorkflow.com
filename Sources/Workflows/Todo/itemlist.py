# -*- coding: utf-8 -*-
import config
import os
from uuid import uuid4
import parser
import yaml
from collections import defaultdict
from datetime import datetime
import helpers

# overall list management

def clear_todos():
	todo_db = config.get('todo.db')
	if ( os.path.exists( todo_db ) ):
		os.remove( todo_db )
	config.update_state(command='clear_todos')

def get_todo_list():
	todos = []
	todoPath = config.get('todo.db')
	if(os.path.exists( todoPath )):
		f = open ( todoPath )
		todos = yaml.load(f)
		if todos is None:
			todos = []
	return todos

def save_todo_list(todos):
	f = open( config.get('todo.db'), 'w')
	yaml.dump(todos, f)

# todo management

def save_todo(raw_task, silent=False):
	info = parser.parse(raw_task)
	tag = info['tag']
	task = info['task']
	pinned = info['pinned']
	rating = info['rating']

	if len(task) == 0:
		return
	if tag is None:
		tag = 'default'

	todos = get_todo_list()
	newtodo = { 
		'title' : task, 
		'created' : datetime.now(), 
		'id' : uuid4(), 
		'group' : tag,
		'pinned' : pinned,
		'rating' : rating
	}
	todos.append ( newtodo )
	save_todo_list(todos)
	if not silent:
		if tag != 'default':
			print "Added '{0}' tagged #{1}".format(task, tag)		
		else:
			print "Added '{0}'".format(task)
	config.update_state(command='add_todo', tag='#'+tag)


def get_todo(_id):
	todos = get_todo_list()
	for todo in todos:
		if str(todo['id']) == _id:
			return todo

def remove_todo(_id):
	todos = get_todo_list()
	if len(todos) > 0 and len(_id) > 0:
		toremove = [t for t in todos if str(t['id']) == _id]
		todos = [t for t in todos if str(t['id']) != _id]
		save_todo_list(todos)
		tag = toremove[0]['group']
		config.update_state(command='remove_todo', tag='#'+tag)
		print "Removed '{0}'".format(toremove[0]['title'])

def update_todo(_id, values):
	todos = get_todo_list()
	if len(todos) > 0 and len(_id) > 0:
		for t in todos:
			if str(t['id']) == _id:
				for key in values:
					t[key] = values[key]
				break
	save_todo_list(todos)

def toggle_pinned(_id):
	todo = get_todo(_id)
	toggle = False if feature(todo,'pinned') else True
	update_todo(_id, {'pinned':toggle})
	config.update_state(command='toggle_pinned',tag='#'+todo['group'])

# tag management

def get_tags():
	todos = get_todo_list()
	tags = defaultdict(list)
	for i in todos: tags[i['group']].append(i['created'])
	return tags

def remove_tag(tag):
	todos = get_todo_list()
	if len(todos) > 0 and len(tag) > 0:
		toremove = [t for t in todos if t['group'] == tag]
		todos = [t for t in todos if t['group'] != tag]
		save_todo_list(todos)
		config.update_state(command='remove_tag', tag='#'+tag)
		print "Removed all items tagged #{2}".format(len(toremove), 'item' if len(toremove) == 1 else 'items', tag)


# generic functions
def remove_item(item):
	if helpers.is_todo(item):
		remove_todo(helpers.extract_todo_id(item))
	elif helpers.is_tag(item):
		remove_tag(helpers.extract_tag(item))

def retrieve_and_store_tag(item):
	tag = 'default'
	if helpers.is_tag(item):
		tag = helpers.extract_tag(item)
	else:
		_id = helpers.extract_todo_id(item)
		todos = get_todo_list()
		target = [t for t in todos if str(t['id']) == _id]
		tag = target[0]['group']
 	config.update_state(command='retrieve_tag', tag='#'+tag)


def copy_todo_to_clipboard(_id):
	todo = get_todo(_id)
	title = todo['title']
	tag = todo['group']
	helpers.macSetClipboard(title)
	config.update_state(command='copy_to_clipboard', tag='#'+tag)
	print "Copied '{0}' to the clipboard".format(title)


# Since these feature have been added late
# and the YAML file will not have these by default
# features should be extracted like this
def feature(todo, feature):
	if feature == 'pinned':
		return get_item_key(todo, feature, False)
	if feature == 'rating':
		return get_item_key(todo, feature, '')
	return todo[feature]

def get_item_key(todo, key, default):
	if key not in todo:
		todo[key] = default
	return todo[key]
