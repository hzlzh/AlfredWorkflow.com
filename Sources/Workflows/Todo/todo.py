import sys
import os
import alfred 
import helpers
import config
import itemlist
import tagview
import itemview

def process_todo_query(raw_query):
	if raw_query == "#":
		tagview.generate_view()
	else:
		itemview.generate_view(raw_query)

def actionize(query):
	if len(query) <= 0:
		return
	have_tag = helpers.is_tag(query)
	have_todo = helpers.is_todo(query)

	if not (have_tag or have_todo):
		itemlist.save_todo(query)
	elif have_todo:
		itemlist.copy_todo_to_clipboard(helpers.extract_todo_id(query))
	elif have_tag:
		config.put('todo.tag.recent', "#"+helpers.extract_tag(query))

def main():
	(option, query) = alfred.args2()
	if option == "-c":
		itemlist.clear_todos()
	elif option == "-a":
		actionize(query)
	elif option == "-q":
		process_todo_query(query)
	elif option == "-r":
		itemlist.remove_item(query)
	elif option == "-v":
		itemlist.retrieve_and_store_tag(query)
	elif option == '-p':
		if helpers.is_todo(query):
			itemlist.toggle_pinned(helpers.extract_todo_id(query))

if __name__ == "__main__":
    main()