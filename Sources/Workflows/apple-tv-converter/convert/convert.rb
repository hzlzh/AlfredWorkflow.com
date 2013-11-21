require File.expand_path(File.join(File.dirname(__FILE__), '..', 'common'))

# Convert any non switch argument (i.e., not starting with a -) to the shell unescaped equivalent
arguments = @command_line_arguments.split(/\~+/).map { |arg| arg =~ /^-/ ? arg : Shellwords.shellsplit(arg).join(' ') }

message = ''
status = read_status

begin
  Dir.chdir cache_dir

  check_prerequisites

  if status[:in_progress]
    puts "Conversion in progress..."
  else
    process = Proc.new do
      begin
        ffmpeg_location = `which ffmpeg`.strip

        require 'apple_tv_converter'
        FFMPEG.ffmpeg_binary = ffmpeg_location.empty? ? "/usr/local/bin/ffmpeg" : ffmpeg_location

        AppleTvConverter::CommandLine.new *arguments

        "Conversion complete!"
      rescue => e
        [
          "An error occured while converting",
          e.message,
          e.backtrace
        ].flatten.join("\n")
      end
    end

    status = { :in_progress => true }
    write_status status

    # write_to_file 'debug.txt', 'x'

    message = with_captured_output(process) do |data|
      status = read_status

      raise Interrupt if status[:cancel] == true

      if data
        if data =~ /processing file (\d+) of (\d+):\s*(.*)\s\]/i
          status[:current_file] = $1
          status[:total_files] = $2
          status[:filename] = $3
        elsif data =~ /^\* transcoding/i
          status[:step] = :transcoding
        elsif data =~ /^\* extracting subtitles/i
          status[:step] = :extract_subtitles
        elsif data.gsub(/\r|\n/, ' ') =~ /progress:\s*(\d+(?:\.\d+)?\%)\s* \((\d+:\d+)?\)/i
          status[:progress] = $1
          status[:elapsed] = $2
        else
          # File.open('./debug.txt', 'a+') { |f| f.write "-#{data.gsub(/\r|\n/, ' ')}-\n"}
        end

        # write_to_file 'debug.txt', "-#{data.gsub(/\r|\n/, ' ')}-\n", true

        write_status status
      end
    end

    status[:in_progress] = false
    write_status status

    puts message
  end
rescue Interrupt
  puts "Conversion process canceled"
rescue => e
  puts e.message # + "\n" + e.backtrace.join("\n")
ensure
  cleanup
end