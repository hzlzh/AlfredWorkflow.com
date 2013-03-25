#!/usr/bin/env ruby
# encoding: utf-8

# ============== = ===========================================================
# Description    : Alfred 2 Google Related Search Workflow
# Author         : Zhao Cai <caizhaoff@gmail.com>
# HomePage       : https://github.com/zhaocai/
# Version        : 0.1
# Date Created   : Sun 10 Mar 2013 09:59:48 PM EDT
# Last Modified  : Tue 19 Mar 2013 08:50:14 PM EDT
# Tag            : [ ruby, alfred, workflow ]
# Copyright      : © 2013 by Zhao Cai,
#                  Released under current GPL license.
# ============== = ===========================================================

($LOAD_PATH << File.expand_path("..", __FILE__)).uniq!

require "rubygems"
require "bundle/bundler/setup"


require 'google-search'
require "lib/alfred_feedback.rb"
require 'uri'

def valid_result?(result, query)
  if query.empty?
    return true 
  end
  r = true
  query_words = query.split(" ")
  s = "#{result.title} #{result.uri}"
  r = true
  query_words.each { |q|
    unless s.include?(q)
      r = false
    end
  }
  r
end

def generate_feedback(query)

  feedback = Feedback.new

  if query.start_with?('related:')
    # not working in ruby 1.8.7
    # query_pattern  = %r{(?<related> ^related: \S* ) (\s|$) (?<query> .*)}x
    query_pattern  = %r{(^related: \S* ) (\s|$) (.*)}x
    m = query_pattern.match(query)
    related_query = m[1]
    query = m[3]
  else
    uri = URI.parse(%x{osascript browser_url.scpt})
    related_query = %Q{related:#{uri.to_s}}
  end
  feedback.add_item({
    :title    => "Search '#{related_query}'",
    :subtitle => "Open brower for more results.",
    :arg      => URI.escape("http://www.google.com/search?as_q=#{related_query}&lr=lang_"),
  })

  search = Google::Search::Web.new(:query => "#{related_query}")


  i = 0
  search.each do |result|
    if valid_result?(result, query)
      feedback.add_item({
        :title    => result.title,
        :subtitle => result.uri,
        :arg      => result.uri,
      })
      i = 1 + i
      break if i > 20
    end
  end


  puts feedback.to_xml
end

if __FILE__ == $PROGRAM_NAME

  query = ARGV.join(" ").strip

  generate_feedback(query)
end


