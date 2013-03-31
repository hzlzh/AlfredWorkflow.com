#!/usr/bin/python

# Recommended storage folders for workflows:
# Volatile:~/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/[bundle id]
# Non-Volatile:~/Library/Application Support/Alfred 2/Workflow Data/[bundle id]

# To any pythoners out there who may read this script: this is probably atrocious code
# but it's my first python script. Forgive me. Maybe join the github development 

# Written by Shawn Patrick Rice
# Post-release help from Clinxs (https://github.com/clintxs)

import alp
import re
import os
import getpass

user = getpass.getuser()

dir = "/Users/" + user + "/Library/Application Support/Alfred 2/Workflow Data/com.help.shawn.rice"
edir = "/Users/" + user + "/Library/Application\ Support/Alfred\ 2/Workflow\ Data/com.help.shawn.rice"

if not os.path.isdir(dir):
	os.makedirs(dir)

output_file = "alfred-help.md"

location = dir + "/" + output_file
file = open(location, "w")

hotmod = {		131072 : "shift",
				262144 : "control",
				262401 : "control", # https://github.com/shawnrice/alfred2-workflow-help/pull/2/files
				393216 : "shift+control",
				524288 : "option",
				655360 : "shift+option",
				786432 : "control+option",
				917504 : "shift+control+option",
				1048576 : "command",
				1179648 : "shift+command",
				1310720 : "control+command",
				1310985 : "control+command", # https://github.com/shawnrice/alfred2-workflow-help/pull/2/files
				1441792 : "shift+control+command",
				1572864 : "option+command",
				1703936 : "shift+option+command",
				1835008 : "control+option+command",
				1966080 : "shift+control+option+command"
}

hotarg = {		0 : "No Argument",
				1 : "Selection in OS X",
				2 : "OS X Clipboard Contents",
				3 : "Text"
}

hotaction = { 	0 : "Pass through to Workflow",
				1 : "Show Alfred"
}

listdir = os.getcwd() + "/../" # there has to be a more elegant way to do this... 
# list of directories in the 

dirs = os.walk(listdir).next()[1]
# walk through the directory list array

workflows = {} # empty dictionary to hold the individual workflow information

for item in dirs:
	if item != "alfred-help": # this is just for my debugging purposes and will disappear soon
			plist = listdir + "/" + item + "/info.plist" # find the plist file
 
 			folder = item # the strange foldernames that Alfred assigns the workflows...
			 
			info = alp.readPlist(plist) # alp function
			
			# start to write the markup for the files 
			
			buffer = "<img src=\"file://localhost/" + listdir + item + "/icon.png\" height=\"50px\">      <font size=\"5em\"><b>" + info['name'] + "</b></font>\n<hr>"
			buffer += "\n\n_(" + info['bundleid'] + ") by " + info['createdby'] + "_\n"
			if "disabled" in info:
				if info['disabled']:
					buffer +=  " (<font color=\"red\">disabled</font>)\n" # Indicate that a workflow is disabled

			if info['description']: # Is the description present? Some people don't include these...
				buffer +=  "######<font color=\"gray\">" + info['description'] + "</font>\n"
			else:
				buffer +=  "\n"
			
			# Start to go through the objects to look for keywords, script filters, and hotkeys
			commands = "\t"
			hotkeys = "\t"
			for item in info['objects']:
				if item['type'] == "alfred.workflow.input.keyword":		# Keywords
					if commands == "\t":
						commands = "\r\n* " + item['config']['keyword']
					else:
						commands += "\r\n* " + item['config']['keyword']
					if "text" in item['config']:
						commands += " (" + item['config']['text'] + ")"
					elif "subtext" in item['config']:
						commands += " (" + item['config']['subtext'] + ")"
				if item['type'] == "alfred.workflow.trigger.hotkey":	# Hotkeys
					if hotkeys != "\t":
						hotkeys += "\n\n"
					if "hotmod" in item['config'] and item['config']['hotmod']:
						if item['config']['hotmod'] in hotmod:
							hotkeys += "\r\n* " + hotmod[item['config']['hotmod']] + " " + item['config']['hotstring']
						else:
							hotkeys += "\r\n* <font color=\"red\">Error reading hotkey</font>: try re-entering the hotkey in Alfred's preferences"
					else:
						hotkeys += "\r\n* " + "<font color=\"red\">Not yet defined</font>" # Hotkeys have to be defined when a user installs a workflow
					if item['config']['argument']:
						hotkeys += " (Takes " + hotarg[item['config']['argument']] + " as an argument)"	# Give any argument information... this should be expanded to be more helpful					
				if item['type'] == "alfred.workflow.input.scriptfilter":	# Keywords from script filters
					if commands == "\t":
						commands = "\r\n* " + item['config']['keyword']
					else:
						commands += "\r\n" + "* " + item['config']['keyword']

					# Grabs explanatory text and subtext. People don't seem to use these in any particular way in that one would be more descriptive than the other
					# So, I'm not sure how to deal with problem to present the best information. This is the current solution that is probably not the best.

					if "subtext" in item['config']:
						commands += " (" + item['config']['subtext'] + ")"
					elif "text" in item['config']:
						commands += " (" + item['config']['text'] + ")"
					elif "title" in item['config']:
						commands += " (" + item['config']['title'] + ")"

			buffer += "\n\n" # Add in a few lines to separate the commands and hotkeys
			
			# Add in the markup for the commands and hotkeys together
			if commands != "\t":						
				buffer += "__Commands__\n" + commands
			if hotkeys != "\t":
				buffer += "\n\n__Hotkeys__\n" + hotkeys
			
			workflows[info['name']] = buffer # add into workflows dictionary with name as key and file markup as the content

buffer = "" # buffer to write for the file

# go through the workflows dictionary, and push those into the file, sorted alphabetically
for key in sorted(workflows.keys(), key=lambda x: x.lower()): 
	buffer += workflows[key] + "\n\n<br><br>"
buffer = buffer.encode('utf-8')	# qlmanage needs this to be in utf-8, so we'll convert the ascii to that
file.write(buffer)
file.close()	# finished generating the file

# display the file with the qlmanage debug tools
command = "qlmanage -p " + edir + "/" + output_file + " -c .md -g libraries/QLMarkdown.qlgenerator >/dev/null 2>&1 &" # create the command. The ">/dev/null 2>&1 &" is there to ignore any output and run the command in the background... otherwise the computer will become unresponsive for a bit, and we all know that's not good.
os.system(command)	# execute the command

# At this point, the script ends, and Alfred has already notified you that the file is being created and could take some time.

##
#			Add in readme files for next version
#			This code doesn't work...
##			
#			if 'readme' in info:
#				readme = info['readme']
#			else:
#				print "No readme file included."				
#			re.sub("^([\#]{1,})([a-zA-Z0-9 :.-]{1,})([\#]{1,})",
#					"<b>\2</b>",
#					readme)
