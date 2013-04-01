# Alfred Workflow Builder

Alfred Workflow Builder is a PHP class for creating workflows with Alfred 2. This class provides functions for working
with plist settings files, reading and writing data to files, generating Alfred feedback results, and more.


## Installation

[Composer](composer) is the recommended way to install is package. Composer is dependency management tool for PHP that
allows you to declare the dependencies your project needs and installs them into your project.

1. Add `skyzyx/alfred-workflow-builder` as a dependency in your project's `composer.json` file.

	```json
	{
	    "require": {
	        "skyzyx/alfred-workflow-builder": "1.0.*"
	    }
	}
	```

2. Download and install Composer.

	```bash
	curl -s "http://getcomposer.org/installer" | php
	```

3. Install your dependencies.

	```bash
	php composer.phar install --optimize-autoloader
	```

4. Require Composer's autoloader.
Composer also prepares an autoload file that's capable of autoloading all of the classes in any of the libraries that
it downloads. To use it, just add the following line to your code's bootstrap process.

	```php
	require 'vendor/autoload.php';
	```

The [original version of this class](original-class) (written by [David Ferguson](dferg)) had methods for things like
caching data to local files and fetching remote data over HTTP. Instead, we recommend you use [Guzzle](guzzle),
[Requests](requests) or [Buzz](buzz) for HTTP requests and [Doctrine Cache][doctrine-cache] for local file system caching.
If you'd also like logging, we recommend [Monolog](monolog).

[buzz]: https://github.com/kriswallsmith/Buzz
[composer]: http://getcomposer.org
[dferg]: http://dferg.us
[doctrine-cache]: http://docs.doctrine-project.org/en/2.0.x/reference/caching.html
[guzzle]: http://guzzlephp.org
[monolog]: https://github.com/Seldaek/monolog
[original-class]: https://github.com/jdfwarrior/Workflows
[requests]: http://requests.ryanmccue.info


## `Alfred\Workflow`

```php
use Alfred\Workflow;

$w = new Workflow('com.ryanparman.my-workflow');
#=> <Alfred\Workflow>
```

### Properties

#### bundle
The bundle ID for the workflow.

```php
$bundle = $w->bundle;
#=> (string) com.ryanparman.my-workflow
```

#### cache
The cache directory for the workflow.

```php
$cache = $w->cache;
#=> (string) /Users/rparman/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/com.ryanparman.my-workflow
```

#### data
The data directory for the workflow.

```php
$data = $w->data;
#=> (string) /Users/rparman/Library/Application Support/Alfred 2/Workflow Data/com.ryanparman.my-workflow
```

#### home
The current user's `$HOME` directory.

```php
$home = $w->home;
#=> (string) /Users/rparman
```

#### path
The working directory for the workflow.

```php
$path = $w->path;
#=> (string) /Users/rparman/Library/Application Support/Alfred 2/Alfred.alfredpreferences/workflows/com.ryanparman.my-workflow
```

#### results
An array containing all of the results so far.

##### Example
```php
$w->result(array(
    'uid' => 'itemuid',
    'arg' => 'itemarg',
    'title' => 'Some Item Title',
    'subtitle' => 'Some item subtitle',
    'icon' => 'icon.png',
    'valid' => 'yes',
    'autocomplete' => 'autocomplete'
));
echo var_export($w->results());
```

##### Results
```php
array (
  0 =>
  array (
    'uid' => 'alfred',
    'arg' => 'alfredapp',
    'title' => 'Alfred',
    'subtitle' => '/Applications/Alfred.app',
    'icon' => 'fileicon:/Applications/Alfred.app',
    'valid' => 'yes',
    'autocomplete' => 'Alfredapp',
  ),
)
```


### Methods

#### `string` toXML()
Accepts a properly formatted array or json object and converts it to XML for creating Alfred feedback results. If results
have been created using the `result()` function, then passing no arguments will use the array of results created using
the `result()` function. Arrays passed in must be an associative array with array key values for the following required
values: `uid`, `arg`, `title`, `subtitle` and `icon`. You may also pass array `key => value` pairs for the following
optional keys: `valid` and `autocomplete`.

##### Example using result function
```php
$w->result(array(
    'uid' => 'itemuid',
    'arg' => 'itemarg',
    'title' => 'Some Item Title',
    'subtitle' => 'Some item subtitle',
    'icon' => 'icon.png',
    'valid' => 'yes',
    'autocomplete' => 'autocomplete'
));
echo $w->toXML();
```

##### Example using array
```php
$results = array();
$temp = array(
    'uid' => 'itemuid',
    'arg' => 'itemarg',
    'title' => 'Some Item Title',
    'subtitle' => 'Some item subtitle',
    'icon' => 'icon.png',
    'valid' => 'yes',
    'autocomplete' => 'autocomplete'
);
array_push($results, $temp);
echo $w->toXML($results);
```

##### Result
```xml
<?xml version="1.0"?>
<items>
    <item uid="itemuid" arg="itemarg" autocomplete="autocomplete">
        <title>Some Item Title</title>
        <subtitle>Some item subtitle</subtitle>
        <icon>icon.png</icon>
    </item>
</items>
```

#### `array` mdfind()
Executes an `mdfind` command and returns results as an array of matching files.

```php
$results = $w->mdfind('"kMDItemContentType == com.apple.mail.emlx"');
/* or */
$results = $w->mdfind('Alfred 2.app');
#=> (array) ['/Applications/Alfred 2.app']
```

#### `array` result()
Creates a new result item that is cached within the class object. This set of results is available via the `results()`
functions, or, can be formatted and returned as XML via the `toXML()` function.

Autocomplete value is optional. If no value is specified, it will take the value of the result title. Possible values
for `$valid` are `yes` and `no` to set the validity of the result item.

##### Example
```php
$w->result(array (
    'uid' => 'alfred',
    'arg' => 'alfredapp',
    'title' => 'Alfred',
    'subtitle' => '/Applications/Alfred.app',
    'icon' => 'fileicon:/Applications/Alfred.app',
    'valid' => 'yes',
    'autocomplete' => 'Alfredapp',
));
echo $w->toXML();
```

##### Result
```xml
<?xml version="1.0"?>
<items>
    <item uid="alfred" arg="alfredapp" autocomplete="Alfredapp">
        <title>Alfred</title>
        <subtitle>/Applications/Alfred.app</subtitle>
        <icon type="fileicon">/Applications/Alfred.app</icon>
    </item>
</items>
```


## `Alfred\Storage\Plist`

```php
use Alfred\Storage\Plist;

$plist = new Plist('com.ryanparman.my-workflow');
#=> <Alfred\Storage\Plist>
```


### Methods

#### `string` setValue()
Stores a key-value pair.

```php
$plist->setValue('username', 'rparman');
```

#### `string` setValues()
Stores a series of key-value pairs.

```php
$plist->setValues(array(
    'username' => 'rparman',
    'password' => 'abc123',
    'zipcode'  => '90210',
));
```

#### `string` getValue()
Retrieves the value of a key.

```php
$username = $plist->getValue('username');
#=> (string) rparman
```
