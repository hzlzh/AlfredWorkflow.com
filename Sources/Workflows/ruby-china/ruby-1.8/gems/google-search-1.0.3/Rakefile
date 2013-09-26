
$:.unshift 'lib'
require 'google-search'
require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new "google-search", Google::Search::VERSION do |p|
  p.author = "TJ Holowaychuk"
  p.email = "tj@vision-media.ca"
  p.summary = "Google Search API"
  p.url = "http://github.com/visionmedia/google-search"
  p.runtime_dependencies << 'json'
end

Dir['tasks/**/*.rake'].sort.each { |f| load f }