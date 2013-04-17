alfred-python
=============

Pythonic and lightweight access to the Alfred workflow API. If you need inspiration of how to use it, look at the following lines:

```python
import alfred

>>> import alfred
>>> print alfred.bundleid
nikipore.alfredpython
>>> print alfred.preferences['description']
Python library for Alfred workflow API
>>> alfred.bundleid
'nikipore.alfredpython'
>>> alfred.preferences['description'] # access to info.plist
'Python library for Alfred workflow API'
>>> alfred.work(volatile=True) # access to (and creation of) the recommended storage paths
'/Users/jan/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/nikipore.alfredpython'
>>> alfred.work(volatile=False)
'/Users/jan/Library/Application Support/Alfred 2/Workflow Data/nikipore.alfredpython'
>>> alfred.config()
'config'
>>> item = alfred.Item({'uid': 1, 'arg': 'some arg'}, 'some title', 'some subtitle')
>>> str(item)
'<item arg="some arg" uid="1"><title>some title</title><subtitle>some subtitle</subtitle></item>'
>>> item = alfred.Item({'uid': alfred.uid(1), 'arg': 'some arg', 'valid': 'no'}, 'some title', 'some subtitle', ('someicon.png', {'type': 'filetype'}))
>>> str(item)
'<item arg="some arg" uid="nikipore.alfredpython-1" valid="no"><title>some title</title><subtitle>some subtitle</subtitle><icon type="filetype">someicon.png</icon></item>'
```

The boilerplate for your Alfred workflow is reduced to something like this:

```python
# -*- coding: utf-8 -*-
(parameter, query) = alfred.args() # proper decoding and unescaping of command line arguments
results = [item(
    attributes= {'uid': alfred.uid(0), 'arg': u'https://www.google.de/q=%s' % query},
    title=parameter,
    subtitle=u'simple access to the Alfred workflow API'
)] # a single Alfred result
xml = alfred.xml(results) # compiles the XML answer
alfred.write(xml) # writes the XML back to Alfred
```

You are also invited to look at the workflows implemented with alfred-python:

* [Access to Firefox Bookmarks and User Input History](https://github.com/nikipore/alfred-firefoxbookmarks)
* [File Action Add to Archive](https://github.com/nikipore/alfred-fileaction-zip)
* [Call with Telephone App](https://github.com/nikipore/alfred-voipcall)

Please feel free to contribute more workflows implemented with alfred-python here, or add functionality to/fix bugs on alfred-python.
