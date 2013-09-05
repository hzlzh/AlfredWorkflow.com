# encoding: utf-8

require 'net/http'
require 'rexml/document'
require 'cgi'
load 'alfred_feedback.rb'

term = CGI::escape(ARGV[0])

# Web search for "madonna"
url = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&retmax=20&term=#{term}"

# get the XML data as a string
xml_data = Net::HTTP.get_response(URI.parse(url)).body

# extract event information
id_doc = REXML::Document.new(xml_data)
ids = []
id_doc.elements.each('eSearchResult/IdList/Id') do |ele|
   ids << ele.text
end

id_list = CGI::escape(ids.join(","))

url = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=#{id_list}&version=2.0"

xml_data = Net::HTTP.get_response(URI.parse(url)).body

sum_doc = REXML::Document.new(xml_data)
summaries = []
sum_doc.elements.each('eSummaryResult/DocumentSummarySet/DocumentSummary') do |ele|
  uid = ele.attributes['uid']
  title = ele.elements['Title'][0].to_s
  url = "http://www.ncbi.nlm.nih.gov/pubmed/#{uid}"
  authors = []
  ele.elements.each('Authors/Author') do |author_ele|
  	authors << author_ele.elements['Name'][0].to_s
  end
  pub_date = ele.elements['PubDate'][0].to_s
  summaries << {:title => title, :uid => uid, :url => url, :authors => authors, :pub_date => pub_date}
end

feedback = Feedback.new
summaries.each do |summary|
	feedback.add_item({:uid => summary[:uid], :title => summary[:title], :subtitle => "#{summary[:pub_date]}: #{summary[:authors].join(', ')}", :arg => summary[:uid]})
end

puts feedback.to_xml

