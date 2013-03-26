# -*- coding: utf-8 -*-
import itemlist
import alfred
import config
import helpers

def generate_view():
	feedback_items = []
	tags = itemlist.get_tags()
	for tag,items in tags.items():
		feedback_items.append(
			alfred.Item(
				attributes = { 
				'uid' : alfred.uid(tag),
				'arg' : helpers.encode_tag(tag),
				'autocomplete' : "#{0} ".format(tag),
				'valid' : 'yes'
				},
				title = "#{0}".format(tag),
				subtitle = "Tag matches {0} item{1}".format(len(items), ('' if len(items) == 1 else 's')),
				icon = "todo_tag.png"
			)
		)
	if len(feedback_items) == 0:
		feedback_items.append(default_no_tags())
		config.update_state(tag='#default')	
	config.update_state(view='tag_view',command='display_tags')
	alfred.write(alfred.xml(feedback_items))


def default_no_tags():
	title = "Sorry, no tags exist"
	subtitle = "Type something to create a new todo"
	return alfred.Item(
		attributes = { 
		'uid' : alfred.uid("notags"),
		'arg' : ''
		},
		title = title,
		subtitle = subtitle,
		icon = "todo_tag.png"
	)
