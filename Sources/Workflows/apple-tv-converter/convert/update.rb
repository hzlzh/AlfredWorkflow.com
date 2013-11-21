@skip_load_apple_tv_converter = true
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'common'))

# Update if needed the Apple TV Converter gem
version = update_remote_gem('apple-tv-converter')
if version
  puts "Successfully updated to version #{version}"
else
  puts "Update not necessary"
end
