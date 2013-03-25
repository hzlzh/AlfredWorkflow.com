Dropbox::API - Dropbox Ruby API client
=========

A Ruby client for the DropBox REST API.

Goal:

To deliver a more Rubyesque experience when using the DropBox API.

Current state:

First release, whole API covered.

Important!!!
------------

From version 0.2.0, Dropbox::API::File#delete and Dropbox::API::Dir#delete *are gone*!!

The reason is that it's based on Hashie::Mash and was screwing Hash#delete.

It is replaced with Dropbox::API::File#destroy and Dropbox::API::Dir#destroy.

Installation
------------

Dropbox::API is available on RubyGems, so:

```
gem install dropbox-api
```

Or in your Gemfile:

```ruby
gem "dropbox-api"
```

Configuration
-------------

In order to use this client, you need to have an app created on https://www.dropbox.com/developers/apps.

Once you have it, put this configuration somewhere in your code, before you start working with the client.

```ruby
Dropbox::API::Config.app_key    = YOUR_APP_TOKEN
Dropbox::API::Config.app_secret = YOUR_APP_SECRET
Dropbox::API::Config.mode       = "sandbox" # if you have a single-directory app or "dropbox" if it has access to the whole dropbox
```

Dropbox::API::Client
--------------------

The client is the base for all communication with the API and wraps around almost all calls
available in the API.

In order to create a Dropbox::API::Client object, you need to have the configuration set up for OAuth.
Second thing you need is to have the user authorize your app using OAuth. Here's a short intro
on how to do this:

```ruby
consumer = Dropbox::API::OAuth.consumer(:authorize)
request_token = consumer.get_request_token
request_token.authorize_url(:oauth_callback => 'http://yoursite.com/callback')
# Here the user goes to Dropbox, authorizes the app and is redirected
# The oauth_token will be available in the params
request_token.get_access_token(:oauth_verifier => oauth_token)
```

Now that you have the oauth token and secret, you can create a new instance of the Dropbox::API::Client, like this:

```ruby
client = Dropbox::API::Client.new :token => token, :secret => secret
```

Rake-based authorization
------------------------

Dropbox::API supplies you with a helper rake which will authorize a single client. This is useful for development and testing.

In order to have this rake available, put this on your Rakefile:

```ruby
require "dropbox-api/tasks"
Dropbox::API::Tasks.install
```

You will notice that you have a new rake task - dropbox:authorize

When you call this Rake task, it will ask you to provide the consumer key and secret. Afterwards it will present you with an authorize url on Dropbox.

Simply go to that url, authorize the app, then press enter in the console.

The rake task will output valid ruby code which you can use to create a client.

What differs this from the DropBox Ruby SDK?
--------------------------------------------

A few things:

* It's using the ruby oauth gem, instead of reinventing the wheel and implementing OAuth communication
* It treats files and directories as Ruby objects with appropriate classes, on which you can perform operations

Consider the following example which takes all files with names like 'test.txt' and copies them with a suffix '.old'

This is how it would look using the SDK:

```ruby
# Because you need the session with the right access token, you need to create one instance per user
@session = DropboxSession.new(APP_TOKEN, APP_SECRET)
@session.set_access_token(ACCESS_TOKEN, ACCESS_SECRET)
@client = DropboxClient.new(@session, :app_folder)
# The result is a hash, so we need to call a method on the client, supplying the right key from the hash
@client.search('/', 'test.txt').each do |hash|
  @client.file_copy(hash['path'], hash['path'] + ".old")
end
```

With Dropbox::API, you can clean it up, first you put the app token and secret in a config or initializer file:

```ruby
Dropbox::API::Config.app_key    = APP_TOKEN
Dropbox::API::Config.app_secret = APP_SECRET
```

And when you want to use it, just create a new client object with a specific access token and secret:

```ruby
# The app token and secret are read from config, that's all you need to have a client ready for one user
@client = Dropbox::API::Client.new(:token  => ACCESS_TOKEN, :secret => ACCESS_SECRET)
# The file is a Dropbox::API::File object, so you can call methods on it!
@client.search('test.txt').each do |file|
  file.copy(file.path + ".old2")
end
```

What differs this from the dropbox gem?
--------------------------------------

Dropbox::API does not extend the Ruby primitives, like the dropbox gem:

https://github.com/RISCfuture/dropbox/tree/master/lib/dropbox/extensions

Dropbox::API::Client methods
----------------------------

### Dropbox::API::Client#account

Returns a simple object with information about the account:

```ruby
client.account # => #<Dropbox::API::Object>
```

For more info, see [https://www.dropbox.com/developers/reference/api#account-info](https://www.dropbox.com/developers/reference/api#account-info)

### Dropbox::API::Client#find

When provided a path, returns a single file or directory

```ruby
client.find 'file.txt' # => #<Dropbox::API::File>
```

### Dropbox::API::Client#ls

When provided a path, returns a list of files or directories within that path

By default it's the root path:

```ruby
client.ls # => [#<Dropbox::API::File>, #<Dropbox::API::Dir>]
```

But you can provide your own path:

```ruby
client.ls 'somedir' # => [#<Dropbox::API::File>, #<Dropbox::API::Dir>]
```

### Dropbox::API::Client#mkdir

Creates a new directory and returns a Dropbox::API::Dir object

```ruby
client.mkdir 'new_dir' # => #<Dropbox::API::Dir>
```

### Dropbox::API::Client#upload

Stores a file with a provided body under a provided name and returns a Dropbox::API::File object

```ruby
client.upload 'file.txt', 'file body' # => #<Dropbox::API::File>
```

### Dropbox::API::Client#download

Downloads a file with a provided name and returns it's content

```ruby
client.download 'file.txt' # => 'file body'
```

### Dropbox::API::Client#search

When provided a pattern, returns a list of files or directories within that path

Be default is searches the root path:

```ruby
client.search 'pattern' # => [#<Dropbox::API::File>, #<Dropbox::API::Dir>]
```

However, you can specify your own path:

```ruby
client.search 'pattern', :path => 'somedir' # => [#<Dropbox::API::File>, #<Dropbox::API::Dir>]
```

### Dropbox::API::Client#delta

Returns a cursor and a list of files that have changed since the cursor was generated.

```ruby
delta = client.delta 'abc123'
delta.cursor # => 'def456'
delta.entries # => [#<Dropbox::API::File>, #<Dropbox::API::Dir>]
```

When called without a cursor, it returns all the files.

```ruby
delta = client.delta 'abc123'
delta.cursor # => 'abc123'
delta.entries # => [#<Dropbox::API::File>, #<Dropbox::API::Dir>]
```

Dropbox::API::File and Dropbox::API::Dir methods
----------------------------

These methods are shared by Dropbox::API::File and Dropbox::API::Dir

### Dropbox::API::File#copy | Dropbox::API::Dir#copy

Copies a file/directory to a new specified filename

```ruby
file.copy 'newfilename.txt' # => #<Dropbox::API::File>
```

### Dropbox::API::File#move | Dropbox::API::Dir#move

Moves a file/directory to a new specified filename

```ruby
file.move 'newfilename.txt' # => #<Dropbox::API::File>
```

### Dropbox::API::File#destroy | Dropbox::API::Dir#destroy

Deletes a file/directory

```ruby
file.destroy 'newfilename.txt' # => #<Dropbox::API::File>
```


Dropbox::API::File methods
----------------------------

### Dropbox::API::File#revisions

Returns an Array of Dropbox::API::File objects with appropriate rev attribute

For more info, see [https://www.dropbox.com/developers/reference/api#revisions](https://www.dropbox.com/developers/reference/api#revisions)

### Dropbox::API::File#restore

Restores a file to a specific revision

For more info, see [https://www.dropbox.com/developers/reference/api#restore](https://www.dropbox.com/developers/reference/api#restore)

### Dropbox::API::File#share_url

Returns the link to a file page in Dropbox

For more info, see [https://www.dropbox.com/developers/reference/api#shares](https://www.dropbox.com/developers/reference/api#shares)

### Dropbox::API::File#direct_url

Returns the link to a file in Dropbox

For more info, see [https://www.dropbox.com/developers/reference/api#media](https://www.dropbox.com/developers/reference/api#media)

### Dropbox::API::File#thumbnail

Returns the thumbnail for an image

For more info, see [https://www.dropbox.com/developers/reference/api#thumbnail](https://www.dropbox.com/developers/reference/api#thumbnail)

### Dropbox::API::File#download

Downloads a file and returns it's content

```ruby
file.download # => 'file body'
```

Dropbox::API::Dir methods
----------------------------

### Dropbox::API::Dir#ls

Returns a list of files or directorys within that directory

```ruby
dir.ls # => [#<Dropbox::API::File>, #<Dropbox::API::Dir>]
```

Testing
---------

In order to run tests, you need to have an application created and authorized. Put all tokens in spec/connection.yml and you're good to go.

Check out spec/connection.sample.yml for an example.

Copyright
---------

Copyright (c) 2011 Marcin Bunsch, Future Simple Inc. See LICENSE for details.
