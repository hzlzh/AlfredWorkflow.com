require File.expand_path(File.join(File.dirname(__FILE__), '..', 'common'))

status = read_status
if status[:in_progress]
  status[:cancel] = true
  write_status status

  puts "Canceling process"
else
  puts "Apple TV Converter not running"
end