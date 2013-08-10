# alfred-workflow [![Build Status](https://travis-ci.org/zhaocai/alfred-workflow.png?branch=master)](https://travis-ci.org/zhaocai/alfred-workflow)

* home  :: http://zhaocai.github.com/alfred2-ruby-template/
* rdoc  :: http://rubydoc.info/gems/alfred-workflow/
* code  :: https://github.com/zhaocai/alfred-workflow
* bugs  :: https://github.com/zhaocai/alfred-workflow/issues


## DESCRIPTION:

alfred-workflow is a ruby Gem helper for building [Alfred](http://www.alfredapp.com) workflow.


## FEATURES:

* Use standard [bundler][gembundler] to easily package, manage, and update ruby gems in the workflow.
* Friendly exception and debug output to the Mac OS X Console.
* Automate saving and loading cached feedback
* Automate rescue feedback items to alfred when something goes wrong.
* Functions to easily load and save user configuration (in YAML)
* Functions for smart case query filter of feedback results.
* Functions for finding the bundle ID, cache and storage paths, and query arguments.
* Functions for reading and writing plist files.
* Functions to simplify generating feedback XML for Alfred.

## INSTALL:

`gem install alfred-workflow`

## USAGE:

* Refer to [alfred2-ruby-template]( https://github.com/zhaocai/alfred2-ruby-template ) for examples and detailed instruction. Also refer to some of the example projects:

* [alfred2-top-workflow]( https://github.com/zhaocai/alfred2-top-workflow )
* [alfred2-google-workflow]( https://github.com/zhaocai/alfred2-google-workflow )
* [alfred2-sourcetree-workflow]( https://github.com/zhaocai/alfred2-sourcetree-workflow )

## SYNOPSIS:

### The Basic
```ruby
require 'rubygems' unless defined? Gem
require "bundle/bundler/setup"
require "alfred"

Alfred.with_friendly_error do |alfred|
  fb = alfred.feedback

  fb.add_file_item(File.expand_path "~/Applications/")

  puts fb.to_alfred(ARGV)
end
```

Code are wrapped in `Alfred.with_friendly_error` block. Exceptions and debug messages are logged to Console log file **~/Library/Logs/Alfred-Workflow.log**.

### With rescue feedback automatically generated!

```ruby
require 'rubygems' unless defined? Gem
require "bundle/bundler/setup"
require "alfred"

def my_code_with_something_goes_wrong
  true
end

Alfred.with_friendly_error do |alfred|
  alfred.with_rescue_feedback = true

  fb = alfred.feedback

  if my_code_with_something_goes_wrong
    raise Alfred::NoBundleIDError, "Wrong Bundle ID Test!"
  end
end
```

![rescue feedback](https://raw.github.com/zhaocai/alfred2-ruby-template/master/screenshots/rescue%20feedback.png)


### Automate saving and loading cached feedback
```ruby
require 'rubygems' unless defined? Gem
require "bundle/bundler/setup"
require "alfred"

Alfred.with_friendly_error do |alfred|
  alfred.with_rescue_feedback = true
  alfred.with_cached_feedback do
    # expire in 1 hour
    use_cache_file :expire => 3600
    # use_cache_file :file => "/path/to/your/cache_file", :expire => 3600
  end

  if fb = alfred.feedback.get_cached_feedback
    # cached feedback is valid
    puts fb.to_alfred
  else 
    fb = alfred.feedback
    # ... generate_feedback as usually
    fb.put_cached_feedback
  end
end
```






## Troubleshooting




## DEVELOPERS:

After checking out the source, run:

  $ rake newb

This task will install any missing dependencies, run the tests/specs,
and generate the RDoc.

## LICENSE:

Copyright (c) 2013 Zhao Cai <caizhaoff@gmail.com>

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option)
any later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see <http://www.gnu.org/licenses/>.


[gembundler]: http://gembundler.com/
[alfredapp]: http://www.alfredapp.com
