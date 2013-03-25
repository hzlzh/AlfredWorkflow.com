
$:.unshift File.dirname(__FILE__) + '/../lib'
require 'pp'
require 'rubygems'
require 'google-search'

def fixture path
  File.read File.dirname(__FILE__) + "/fixtures/#{path}"
end

def json_fixture name
  Google::Search.json_decode fixture("#{name}.json")
end