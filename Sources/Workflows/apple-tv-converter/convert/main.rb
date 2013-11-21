# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'common'))

Alfred.with_friendly_error do |alfred|
  fb = alfred.feedback

  arguments = @command_line_arguments.split(/\\?\$+/).map { |a| a.strip.length == 0 ? nil : a.strip }.compact
  number_of_dirs = 0
  number_of_files = 0

  arguments_command_line = [
    '--os',             # Fetch subtitles
    '-leng,por',       # Limit subtitles and audio streams to english and portuguese
    '--no-interactive'  # No interaction
  ]

  arguments.each do |arg|
    if File.directory?(arg)
      arguments_command_line << %Q[-d #{Shellwords.escape arg}]
      number_of_dirs += 1
    end
    if File.file?(arg)
      arguments_command_line << %Q[#{Shellwords.escape arg}]
      number_of_files += 1
    end
  end

  title = "Convert "

  if (number_of_dirs + number_of_files) == 1
    title << File.basename(arguments.first)
  else
    title << "#{number_of_dirs} #{number_of_dirs > 1 ? 'directories' : 'directory'} " if number_of_dirs > 0

    if number_of_files > 0
      title << "& " if number_of_dirs > 0
      title << "#{number_of_files} #{number_of_files > 1 ? 'files' : 'file'} "
    end
  end

  if number_of_files + number_of_dirs > 0
    fb.add_item({
      :uid      => "-1",
      :title    => "Convert",
      :subtitle => title,
      :arg      => arguments_command_line.join('~~~'),
      :valid    => "yes",
    })

    fb.add_item({
      :uid      => "-2",
      :title    => "Convert and rename to Plex format",
      :subtitle => title,
      :arg      => (arguments_command_line + ['--plex']).join('~~~'),
      :valid    => "yes",
    })
  else
    fb.add_item({
      :uid      => "1",
      :title    => "Please choose some files/directories on Finder",
      :subtitle => "You can also use Path Finder",
      :arg      => '',
      :valid    => "no",
    })
  end

  puts fb.to_xml
  # result ="--#{ARGV}--#{arguments}--"
  # result = arguments_command_line
end