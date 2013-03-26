import config
import sys
import os
import shutil
import alfred

def update_todo_db_path(path_for_todo_db):
	# before updating the config, check if a todo file
	# is already present. If yes, move existing file to the
	# new location.
	# If a file already exists at the destination, issue a warning
	new_todo_db = os.path.join(path_for_todo_db, "todo.yaml")
	if os.path.exists(new_todo_db):
		print "Oops! Looks like a todo.yaml file already exists in {0}".format(path_for_todo_db)
		return

	old_todo_db = config.get('todo.db')
	if os.path.exists(old_todo_db):
		shutil.move(old_todo_db, path_for_todo_db)
	
	config.put('todo.db', new_todo_db)
	print "'{0}' is now configured as your Todo database folder".format(path_for_todo_db)

def reset():
	config.reset(config.pref_path())

def main():
	(command, data) = alfred.args2()
	if command == "-set-folder":
		update_todo_db_path(data)
	elif command == "-reset":
		reset()


if __name__ == "__main__":
    main()