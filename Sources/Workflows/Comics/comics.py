# Comics works on a plugin principle, allowing easy
# option to add more comics
# To create a new comic entry, create a relevant folder
# under the plugins directory. In there, create a main.py module
# that has a few methods (see an existing example)
# In the run() method, you can do ***** whatever ***** you want
# (though you probably shouldn't!)


import imp
import os
import alfred
import sys
from optparse import OptionParser

PluginFolder = "./plugins"
MainModule = "main"

def getPlugins():
    plugins = []
    possibleplugins = os.listdir(PluginFolder)
    for i in possibleplugins:
        location = os.path.join(PluginFolder, i)
        if not os.path.isdir(location) or not MainModule + ".py" in os.listdir(location):
            continue
        info = imp.find_module(MainModule, [location])
        plugins.append({"name": i, "info": info, "location": location})
    return plugins

def loadPlugin(plugin):
    return imp.load_module(MainModule, *plugin["info"])

def runPlugin(name):
	target = next(i for i in getPlugins() if name == i["name"])
	plugin = loadPlugin(target)
	if ( plugin.enabled() ):
		plugin.run();

def searchComics(search_term):
	feedback_items = []
	for i in getPlugins():
		plugin = loadPlugin(i)
		title = plugin.title()
		subtitle = plugin.subtitle()
		should_add = (plugin.enabled() 
			and (search_term == None 
				or title.lower().find(search_term.lower()) >= 0 
				or subtitle.lower().find(search_term.lower()) >= 0)
			)
		if should_add:	
			feedback_items.append(
				alfred.Item(
					attributes = { 
					'uid' : alfred.uid(i["name"]),
					'arg' : i["name"]
					},
					title = title,
					subtitle = subtitle,
					icon = os.path.join(i["location"], "icon.png")
				)
			)
	xml = alfred.xml(feedback_items)
	alfred.write(xml)

def loadComic(comic_id):
	runPlugin(comic_id)

def comics():
	parser = OptionParser()
	parser.add_option("-s", "--search", dest="search", 
				  help="seach for a comic", metavar="SEARCH_TERM")
	parser.add_option("-l", "--load", dest="load", 
				  help="load a comic", metavar="COMIC_ID")
	(options, args) = parser.parse_args()

	if(options.load == None):
		searchComics(options.search)
	else:
		loadComic(options.load)


if __name__ == "__main__":
    comics()
