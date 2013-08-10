require './alfred_feedback.rb'

query    = ARGV[0].strip.downcase
feedback = Feedback.new

Dir.foreach('/Volumes') do |f|
  path = "/Volumes/#{f}"
  feedback.add_item(
    :title    => f,
    :subtitle => "Open volume",
    :arg      => path,
    :icon     => { :type => "fileicon", :name => path }
  ) if f.downcase =~ /#{query}/ && f != '.' && f != '..' && File.directory?(path)
end

puts feedback.to_xml
