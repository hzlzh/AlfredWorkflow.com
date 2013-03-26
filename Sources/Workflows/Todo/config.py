import alfred
import yaml
import os
import sys

# Gets the key value of
# preference
def get(key):
	p = load()
	if key in p:
		return p[key]
	return "todo.keyvalue.none"

# Updates the value
# of the specified key
def put(key, value):
	p = load()
	p[key] = value;
	save(p)
	pass

# Loads the current preferences
def load():
	init()
	f = open ( pref_path() )
	p = yaml.load(f)
	return p

def save(p):
	f = open( pref_path(), 'w')
	yaml.dump(p, f)

def default_pref():
	return { 'todo.db' : default_todo_path(), 'todo.tag.recent' : '#default' }

def reset(path):
	p = default_pref()
	f = open( path, 'w')
	yaml.dump(p, f)

# if no preferences exists,
# create the default one
def init():
	path = pref_path()
	if not os.path.exists( path ):
		reset(path)
	return

def pref_path():
	return os.path.join ( alfred.work(False), "config.yaml" )

def default_todo_path():
	return os.path.join ( alfred.work(False), "todo.yaml" )

def update_state(view=None, command=None, tag=None, query=None):
	if view is not None:
		put('todo.view.last', view)
	if command is not None:
		put('todo.command.last', command)
	if tag is not None:
		put('todo.tag.recent', tag)
	if query is not None:
		put('todo.user.query', query)

def main():
	(command, data) = alfred.args2()
	if command == '-load':
		print load()
	elif command == '-default':
		print default_pref()
	elif command == '-path':
		print pref_path()
	elif command == '-get':
		value = get(data)
		if value != '':
			print value
	elif command == '-put':
		put(sys.argv[2], sys.argv[3])
	elif command == '-init':
		init()
	elif command == "-reset":
		reset(pref_path())

	pass

if __name__ == "__main__":
    main()