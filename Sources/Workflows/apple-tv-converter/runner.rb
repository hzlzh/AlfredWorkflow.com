# /usr/bin/ruby
require 'shellwords'
rubies = `~/.rvm/bin/rvm list`.split.select do |l|
  l.include?('ruby-')
end.map(&:strip).map do |l|
  # match = l.match(/^ruby-((?:2\.0\.0)|(?:1\.9\.3))-p(\d+)/i)
  match = l.match(/^ruby-((?:1\.9\.3))-p(\d+)/i)
  if match
    version, patch_level = match[1..2]
    [version.gsub(/\./, '').to_i * 1000 + patch_level.to_i, "ruby-#{version}-p#{patch_level}"]
  end
end.compact.sort do |a, b|
  -(a[0] <=> b[0])
end

current_ruby = rubies.first[1]

script = "./convert/#{ARGV[0]}.rb"
parameter = %Q[#{ARGV[1..-1].map { |a| Shellwords.escape a } if ARGV.length > 1}]
command_line = "~/.rvm/rubies/#{current_ruby}/bin/ruby #{script} #{parameter} 2>&1"
# puts ARGV.count
# puts command_line
puts `#{command_line}`