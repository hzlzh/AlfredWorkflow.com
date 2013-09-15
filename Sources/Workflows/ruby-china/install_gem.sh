#!/bin/bash

# If you'd like to package some Ruby 1.8 compatible rubygems with your bundle,
# here's how to install them in the bundle's ruby-1.8 directory:
#
# Sometimes, gems don't like spaces in directory names. Since the Alfred workflow
# directory looks something like:
#
# /Users/yourname/Library/Application Support/Alfred 2/...
#
# You'll often need to install gems in a temporary directory first, then move
# them into the workflow bundle's gem directory. Assuming you are in the
# workflow bundle directory that you want to install a gem to:

if [[ `pwd` == *"Library/Application Support/Alfred 2/Alfred.alfredpreferences/workflows/"* ]]; then

  # Create a 'gems' folder in /tmp
  mkdir -p /tmp/gems
  mkdir ./ruby-1.8/

  # Use the native Mac OS X version of Ruby
  /usr/bin/gem install $1 --no-rdoc --no-ri --install-dir /tmp/gems/

  # Copy the directory structure over top of the ruby-1.8 directory structure
  cp -vR /tmp/gems/ ./ruby-1.8/

  # Clean up
  rm -rf /tmp/gems
else
  echo "Use this command from within the Alfred 2 workflows directory"
fi