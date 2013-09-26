
$:.unshift File.dirname(__FILE__) + '/../lib'
require 'rubygems'
require 'google-search'

def find_item uri, query
  search = Google::Search::Web.new do |search|
    search.query = query
    search.size = :large
    search.each_response { print '.'; $stdout.flush }
  end
  search.find { |item| item.uri =~ uri }
end

def rank_for query
  print "%35s " % query
  if item = find_item(/vision\-media\.ca/, query)
    puts " #%d" % (item.index + 1)
  else
    puts " Not found"
  end
end

rank_for 'Victoria Web Training'
rank_for 'Victoria Web School'
rank_for 'Victoria Web Design'
rank_for 'Victoria Drupal'
rank_for 'Victoria Drupal Development'