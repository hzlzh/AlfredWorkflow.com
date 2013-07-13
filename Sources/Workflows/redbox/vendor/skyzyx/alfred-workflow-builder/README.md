# Alfred Workflow Builder

Alfred Workflow Builder is a PHP class for creating workflows with Alfred 2. This class provides functions for working
with plist settings files, reading and writing data to files, generating Alfred feedback results, and more.


## Installation

[Composer](http://getcomposer.org) is the recommended way to install is package. Composer is dependency management tool
for PHP that allows you to declare the dependencies your project needs and installs them into your project.

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

The [original version of this class](https://github.com/jdfwarrior/Workflows) (written by [David Ferguson](http://dferg.us))
had methods for things like caching data to local files and fetching remote data over HTTP. Instead, we recommend you use
[Guzzle](http://guzzlephp.org), [Requests](http://requests.ryanmccue.info) or [Buzz](https://github.com/kriswallsmith/Buzz)
for HTTP requests and [Doctrine Cache](http://docs.doctrine-project.org/en/2.0.x/reference/caching.html) for local file
system caching. If you'd also like logging, we recommend [Monolog](https://github.com/Seldaek/monolog).

----

## `Alfred\Workflow`

```php
use Alfred\Workflow;

// Pass a Bundle ID
$w = new Workflow('com.ryanparman.my-workflow');
#=> <Alfred\Workflow>
```

### `string` toXML()
Accepts a properly formatted array or json object and converts it to XML for creating Alfred feedback results. If results
have been created using the `result()` function, then passing no arguments will use the array of results created using
the `result()` function.

#### Example using result function
```php
$w->result(array(
    'uid'          => 'itemuid',
    'arg'          => 'itemarg',
    'title'        => 'Some Item Title',
    'subtitle'     => 'Some item subtitle',
    'icon'         => 'icon.png',
    'valid'        => 'yes',
    'autocomplete' => 'autocomplete'
));
echo $w->toXML();
```

#### Example using array
```php
$results = array();
$temp = array(
    'uid'          => 'itemuid',
    'arg'          => 'itemarg',
    'title'        => 'Some Item Title',
    'subtitle'     => 'Some item subtitle',
    'icon'         => 'icon.png',
    'valid'        => 'yes',
    'autocomplete' => 'autocomplete'
);
array_push($results, $temp);
echo $w->toXML($results);
```

#### Result
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

### `array` mdfind()
Executes an `mdfind` command and returns results as an array of matching files.

```php
$results = $w->mdfind('"kMDItemContentType == com.apple.mail.emlx"');
/* or */
$results = $w->mdfind('Alfred 2.app');
#=> (array) ['/Applications/Alfred 2.app']
```

You can learn more about querying the OS X metadata service by checking out:
* [Using Spotlight from the OS X Commandline](http://0xfe.blogspot.com/2006/03/using-spotlight-from-os-x-commandline.html)
* [File Metadata Query Expression Syntax](https://developer.apple.com/library/mac/#documentation/carbon/conceptual/spotlightquery/concepts/queryformat.html)
* [Spotlight Metadata Attributes](https://developer.apple.com/library/mac/#documentation/carbon/Reference/MetadataAttributesRef/Reference/CommonAttrs.html#//apple_ref/doc/uid/TP40001694-SW1)

### `array` result()
Creates a new result item that is cached within the class object. This set of results is available via the `results()`
functions, or, can be formatted and returned as XML via the `toXML()` function.

<table>
    <thead>
        <tr>
            <th>Key</th>
            <th>Usage</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td><code>uid</code></td>
            <td><p>Unique ID for the search result. (Required)</p></td>
        </tr>
        <tr>
            <td><code>arg</code></td>
            <td><p>Argument for this result. This will get fed into any downstream actions. (Required)</p></td>
        </tr>
        <tr>
            <td><code>title</code></td>
            <td><p>The main title for the result. (Required)</p></td>
        </tr>
        <tr>
            <td><code>subtitle</code></td>
            <td><p>The subtitle for the result. (Required)</p></td>
        </tr>
        <tr>
            <td><code>icon</code></td>
            <td><p>The icon that this result should have. This should typically be <code>icon.png</code>. (Required)</p></td>
        </tr>
        <tr>
            <td><code>valid</code></td>
            <td><p>If you press enter with this result selected, should it trigger downstream actions? Valid values are
                <code>"yes"</code>, <code>"no"</code>, <code>true</code> and <code>false</code>. The default value is
                <code>"yes"</code>.</p></td>
        </tr>
        <tr>
            <td><code>autocomplete</code></td>
            <td><p>If you press enter with this result selected, what value should pop up as an autocomplete value?
                (<a href="http://simonbs.dk/post/41727742869/movies-workflow-for-alfred-2-0">Movies</a> is a good usage
                example.)</p></td>
        </tr>
    </tbody>
</table>

#### Example
```php
$w->result(array (
    'uid'          => 'alfred',
    'arg'          => 'alfredapp',
    'title'        => 'Alfred',
    'subtitle'     => '/Applications/Alfred.app',
    'icon'         => 'fileicon:/Applications/Alfred.app',
    'valid'        => 'yes',
    'autocomplete' => 'Alfredapp',
));
echo $w->toXML();
```

#### Result
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

----

## `Alfred\Storage\Plist`

```php
use Alfred\Storage\Plist;

// Pass a Bundle ID and Plist name
$plist = new Plist('com.ryanparman.my-workflow', 'info');
#=> <Alfred\Storage\Plist>
```

### `string` setValue()
Stores a key-value pair.

```php
$plist->setValue('username', 'rparman');
```

### `string` setValues()
Stores a series of key-value pairs.

```php
$plist->setValues(array(
    'username' => 'rparman',
    'password' => 'abc123',
    'zipcode'  => '90210',
));
```

### `string` getValue()
Retrieves the value of a key.

```php
$username = $plist->getValue('username');
#=> (string) rparman
```

## More!
You can learn more about Alfred 2 Workflows by checking out <http://support.alfredapp.com/workflows>.

You can also deconstruct some workflows that are built with Alfred Workflow Builder.
* [Packagist](https://github.com/skyzyx/packagist.alfredworkflow)
* [Geolocation](https://github.com/skyzyx/geolocation.alfredworkflow)
* [Mimetypes](https://github.com/skyzyx/mimetypes.alfredworkflow)
