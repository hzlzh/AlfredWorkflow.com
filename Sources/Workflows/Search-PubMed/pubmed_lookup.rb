# encoding: utf-8

require 'net/http'
require 'rexml/document'
require 'cgi'
load 'alfred_feedback.rb'

term = CGI::escape(ARGV[0])

# Web search for "madonna"
url = "http://www.ncbi.nlm.nih.gov/portal/utils/autocomp.fcgi?q=#{term}&dict=pm_related_queries_2"

# get the data as a string
autocomplete_data = Net::HTTP.get_response(URI.parse(url)).body

results = eval ("[" + autocomplete_data[(autocomplete_data.index('Array(')+6)..-8] + "]")

feedback = Feedback.new
results.each do |autocomplete|
	feedback.add_item({:title => autocomplete, :subtitle => "Search for '#{autocomplete}'", :arg => autocomplete})
end

puts feedback.to_xml
