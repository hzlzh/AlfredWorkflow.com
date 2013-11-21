require File.expand_path(File.join(File.dirname(__FILE__), '..', 'common'))

if @installed
  puts "Apple TV Converter was installed"
else
  status = read_status
  if status[:installing]
    puts "Apple TV Converter is being installed, please wait..."
  elsif status[:in_progress]
    message = "Apple TV Converter is running:\n"
    message << "- "
    message << "[#{status[:current_file]}/#{status[:total_files]}] " if status[:total_files] && status[:total_files].to_i > 1
    message << "#{status[:filename]}\n"

    if [:transcoding, :extract_subtitles].include?(status[:step])
      message << "- Transcoding" if status[:step] == :transcoding
      message << "- Extracting subtitles" if status[:step] == :extract_subtitles

      message << ": #{status[:progress]}" if status[:progress]
      message << " (Elapsed: #{status[:elapsed]})" if status[:elapsed]
    else
      message << "- Running"
    end

    puts message
  else
    puts "Apple TV Converter not running"
  end
end