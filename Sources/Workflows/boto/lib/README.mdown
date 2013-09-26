# alp: A Python Module for Alfred Workflows
Formerly PyAl, alp has been trimmed and slimmed to make building [Alfred v2][] workflows even easier. Not much was lost in the transition---and indeed, some neat things were gained---and so making the transition from PyAl to alp should be relatively easy. All in all, the module is intended to result in fewer lines of repeated code and easy accessibility for newcomers to workflow construction in Alfred and with Python.

alp's primary features include:

* Functions for finding your bundle ID, cache and storage paths, and query arguments.
* Functions for reading and writing JSON and plist files.
* A function to perform fuzzy searching operations.
* A class to simplify generating [feedback XML](http://www.alfredforum.com/topic/5-generating-feedback-in-workflows/) for Alfred.
* A class to simplify saving and retrieving settings.
* A class to interface with the OS X Keychain.
* A class to send notifications to Mac OS X 10.8's Notification Center.
* A class to send notifications and information over e-mail.
* Several bundled modules for working with HTTP requests.

However, you can pick and choose from among these by deleting any of the files in the module (except for `core.py` and the folder `core_dependencies`); if something is missing, alp will silently ignore it.

To get started, simply download or clone this repository and copy the `alp` folder into your workflow directory, then `import alp`. A list of everything alp can do, with appropriate documentation, is below.

## Core Functions
These are intended to make some basic rote tasks easier and faster to code. alp defines the following functions:

* `alp.bundle()`  
    This function returns the bundle ID for your workflow by reading it from its `Info.plist` file.
* `alp.args()`  
    Returns a UTF-8 normalized list of the arguments passed to the script, which are normally separated by spaces. (Thanks to [nikipore](https://github.com/nikipore) for the idea and the tip about `unicodedata`.)
* `alp.decode(s)`  
    Returns a UTF-8 normalized string for `s`.
* `alp.local(join=None)`, `alp.cache(join=None)`, `alp.storage(join=None)`  
    These functions return the paths to, respectively, the workflow's local directory, the workflow's designated cache (volatile storage) directory, and the workflow's designated storage (nonvolatile storage) directory. The directories will be created if they do not exist. By specifying an argument for `join`, you can have a file or folder name appended to the path---however, _this file or folder will not be created_.
* `alp.readPlist(path)`, `alp.writePlist(path)`, `alp.jsonLoad(path, default=None)`, `alp.jsonDump(path)`  
    These functions will read from and write to the plist or JSON files located at `path`. If `path` is not an absolute path, they will treat it as a filename in the storage directory (so, for example, you could call `alp.jsonDump(yourFancyObject, "dump.json")` without any problems. `jsonLoad` has one additional argument, `default`, specifying the object to be dumped and returned if the JSON file did not already exist. For example, calling `alp.jsonLoad("foo.json", default=[])` would load `foo.json` with an empty list if the file was not found.
* `alp.find(query)`  
    Calls `mdfind` with the arguments given in `query`, splitting the results into a list and returning it. For more information, see [`mdfind (1)`](https://developer.apple.com/library/mac/#documentation/Darwin/Reference/ManPages/man1/mdfind.1.html).
* `alp.log(s)`  
    Writes `s` to a file called `debug.log` in the workflow's main folder.


## Feedback System
alp uses a robust and complete implementation of Alfred's feedback system, generating and outputting the required XML for the attributes you specify. This breaks down into a class called `Item` and a function called `feedback`.

* `alp.Item(**kwargs)`  
    The `Item` class is initialized with a list of keys and values, and returns one `Item` which can then be passed to the `feedback` function. The following keys are currently understood by alp and Alfred:

    + `title`: The title string to show in the feedback list.
    + `subtitle`: The subtitle string to show below the title.
    + `uid`: A unique identifier string for Alfred's sorting functions.
    + `valid`: Either `True`, `False`, or a string. Tells Alfred whether the item is actionable.
    + `autocomplete`: A string to autocomplete Alfred's query to when an invalid item is chosen.
    + `icon`: A path to an icon image, a path to a file, or a file type (default: `icon.png`).
    + `fileIcon`: If you wish to use a particular file's icon, set `icon` to its path and `fileIcon` to `True`.
    + `fileType`: If you wish to specify a type of file whose icon Alfred should use, set `icon` to the type and `fileType` to `True`.
    + `arg`: The argument to be passed as `{query}` if the item is valid and actioned. If it contains newlines, it will be passed as a separate XML key rather than an attribute of `<item></item>`.
    + `type`: Currently, can only be set to `file`, which tells Alfred to treat the result as a file.

    A nifty trick is to pass a dictionary with some or all of `alp.Item`'s keys and values into the initializer. So you could conceivably do this:

        >>> iDict = dict(title="A Title", subtitle="This is only a test.", uid="alp-test", valid=False)
        >>> i = alp.Item(**iDict)

* `Item.copy()`  
    Returns one copy of the item, which can then be modified separately and reused.
* `Item.get()`  
    Returns the current values for the item in the following format. Primarily used with the `feedback()` function below.

        {
            "data":
            {
                "content":
                {
                    "title": self.title,
                    "subtitle": self.subtitle,
                    "icon": self.icon,
                    "fileIcon": self.fileIcon,
                    "fileType": self.fileType
                },
                "attrib":
                {
                    "uid": self.uid,
                    "valid": self.valid
                }
            }
        }

    If `autocomplete` or `type` is set, that value will be added to the `"attrib"` dictionary, as will an `arg` that does not contain newlines.
* `alp.feedback(items)`  
    Takes either an individual item or a list of items for `items` and prints a UTF-8-encoded XML string for Alfred to interpret.


## Fuzzy Search
Github user [jlegewie](https://github.com/jlegewie) has contributed a stellar fuzzy-searching method to alp. Given a query, a list of strings, dictionaries, tuples, or other lists, and a key function, it returns a ranked list of matching objects. To use it, first get your data into an appropriate list, then call `alp.fuzzy_search()` with the following parameters: `alp.fuzzy_search(query, elements, key, rank, seq)`. [jlegewie](https://github.com/jlegewie) has provided the following example:

    elements = [{'key': u'ZB7K535R', 'author': u'Reskin 2003', 'title': u'Including Mechanisms in Our Models of Ascriptive Inequality: 2002 Presidential Address'}, {'key': u'DBTD3HQS', 'author': u'Igor & Ronald 2008', 'title': u'Die Zunahme der Lohnungleichheit in der Bundesrepublik. Aktuelle Befunde f\xfcr den Zeitraum von 1998 bis 2005'}, {'key': u'BKTCNEGP', 'author': u'Kirk & Sampson 2013', 'title': u'Juvenile Arrest and Collateral Educational Damage in the Transition to Adulthood'}, {'key': u'9AN4SPKT', 'author': u'Turner 2003', 'title': u'The Structure of Sociological Theory'}, {'key': u'9M92EV6S', 'author': u'Bruhns et al. 1999', 'title': u'Die heimliche Revolution'}, {'key': u'25QBTM5P', 'author': u'Durkheim 1997', 'title': u'The Division of Labor in Society'}, {'key': u'MQ3BHTBJ', 'author': u'Marx 1978', 'title': u'Alienation and Social Class'}, {'key': u'7G4BRU45', 'author': u'Marx 1978', 'title': u'The German Ideology: Part I'}, {'key': u'9ANAZXQB', 'author': u'Llorente 2006', 'title': u'Analytical Marxism and the Division of Labor'}]
    query = 'marx'
    results = fuzzy_search(query, elements, key=lambda x: '%s - %s' % (x['author'], x['title']))

As you can see, the `key` access function should extract a searchable string from your data set, and the `elements` argument should be a list that eventually contains strings. The neat thing about this being a _fuzzy_ search is that `mrx` would also match many of the Marx elements, and if a mistyped or fragmented query is closer to one good candidate (say "Max") than another (like "Marx"), results will be ranked accordingly.


## Notifications
The fact that Alfred's internal workflow workings only make it possible for a workflow to output one string can be frustrating. Enter alp's `Notification` class. It's used a little something like this:

    >>> import alp
    >>> n = alp.Notification()
    >>> n.notify("Title", "Subtitle", "Informative Text")

The title, subtitle, and informative text should be strings. This will pop up a notification that bears Python's logo but is otherwise indistinguishable from any of Alfred's notices. Currently, this is restricted to sending messages to the user---there's not yet a way to know whether the user clicks the notification, for example---but the problem is being worked on.


## HTTP Requests
The modules [Requests](http://docs.python-requests.org/en/latest/), [requests_cache](https://readthedocs.org/projects/requests-cache/), and [BeautifulSoup](http://www.crummy.com/software/BeautifulSoup/) are bundled with alp by default. (N.B.: Because they are relatively large, they can be removed from the module by deleting the folder `request`.) They vastly simplify making and interpreting HTTP requests. The alp `Request` class provides a quick-and-dirty interface to them, setting up a requests cache, making a request, and passing the returned data to BeautifulSoup for parsing.

* `alp.Request(url, payload=None, post=False, cache_for=None)`  
    The class is initialized with a URL to request, an optional key--value dictionary of arguments to pass to the URL, an optional demand that the request be POSTed, and an optional timeout---in seconds---for the cache. (By default, the cache lasts one day; pass a negative value to prevent it from expiring.) The object will then have its own `request` property, which is a Requests object and can be manipulated in any way that a standard Requests object can (see [the documentation](http://docs.python-requests.org/en/latest/) for more info).
* `Request.souper()`  
    This will return a BeautifulSoup object for the data pulled by your request, or else raise an exception if the request failed. BeautifulSoup makes parsing markup language much simpler; see [its documentation](http://www.crummy.com/software/BeautifulSoup/bs4/doc/) for more information.
* `Request.clear_cache()`  
    Clears the cache being used by `requests_cache` immediately.


## Settings Interface
The alp `Settings` object loads and saves settings in your workflow's designated storage path. On initialization, it looks for a settings file, creating it if it fails to find one and loading the predefined settings if it succeeds. It also defines the following methods:

* `Settings.set(**kwargs)`  
    Load the key--value pairs defined in `**kwargs` into memory and saves them to the settings file.
* `Settings.get(k, default=None)`  
    Searches the loaded settings for key `k`, optionally returning `default` if no setting is found.
* `Settings.delete(k)`  
    Unloads the setting for key `k` from memory and deletes it from the settings file.


## Keychain Interface
If your workflow needs to store a user's sensitive data, particularly a username--password pair, the safest way to do so is with the Mac OS X Keychain. The Keychain is normally an utter pain in the behind, but alp makes working with it a breeze. Simply initialize `alp.Keychain(service)` with a service name---for example, your workflow's bundle ID---and then use the following methods:

* `Keychain.storePassword(account, password)`  
    Saves the password securely under the given account name.
* `Keychain.retrievePassword(account)`  
    Searches the Keychain for an account matching the passed string, returning the password. Note that your script currently only has access to passwords defined by your script; you cannot start out searching for, say, "Twitter" and expect to come up with anything.
* `Keychain.modifyPassword(account, newPassword)`
    Changes the saved password for `account` to `newPassword`.
* `Keychain.deletePassword(account)`
    Removes `account`'s password from the Keychain.


## E-mail
By request, alp can also send simple plaintext messages over e-mail. Initialize the `alp.Mail()` object with the following parameters: `alp.Mail(host, port, SSL, user, pw, sender, to, mimetype, subject, body)`. `SSL` should be set to `True` or `False`. `mimetype` should be a string specifying the MIME subtype under "text/" and defaults to "plain" if `None` is passed. `to` can be either a single e-mail address or a list of e-mail addresses. Use `Mail.notify()` to send your message(s):

    >>> e = alp.Mail(host, port, SSL, user, pw, sender, to, mimetype, subject, body)
    >>> e.notify()

See the list of exceptions that can be raised [in the docs](http://docs.python.org/2/library/smtplib.html).


## Help and Support
The [Alfred v2 forums](http://www.alfredforum.com) are a good place to look for answers, but you can also reach this package's maintenance man, [Daniel](http://daniel.sh), at d atsign daniel dot sh or on Twitter at [@phyllisstein](http://twitter.com/phyllisstein/).


## License
alp and all of its components are free to use and distribute however you see fit. Go hog-wild. The author appreciates getting some credit for his work, and the authors of Requests, requests_cache, BeautifulSoup, [six](https://bitbucket.org/gutworth/six/), and [biplist](https://github.com/wooster/biplist/) probably do as well, so it'd be neat if you'd mention us all somewhere. Additionally, donations are gratefully accepted over at [my Alfred website](http://alfred.daniel.sh).



[Alfred v2]: http://www.alfredapp.com
