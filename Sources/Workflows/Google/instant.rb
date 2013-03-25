#!/usr/bin/env ruby
# encoding: utf-8

# ============== = ===========================================================
# Description    : Alfred 2 Google Instant Search Workflow
# Author         : Zhao Cai <caizhaoff@gmail.com>
# HomePage       : https://github.com/zhaocai/
# Version        : 0.1
# Date Created   : Sun 10 Mar 2013 09:59:48 PM EDT
# Last Modified  : Sat 23 Mar 2013 10:00:27 PM EDT
# Tag            : [ ruby, alfred, workflow ]
# Copyright      : © 2013 by Zhao Cai,
#                  Released under current GPL license.
# ============== = ===========================================================

($LOAD_PATH << File.expand_path("..", __FILE__)).uniq!

require "rubygems"
require "bundle/bundler/setup"


require 'google-search'
require "lib/alfred_feedback.rb"


def generate_feedback(query)

  search = Google::Search::Web.new(:query => "#{query}")

  feedback = Feedback.new

  feedback.add_item({
    :title    => "Search '#{query}'",
    :subtitle => "Open brower for more results.",
    :arg      => URI.escape("http://www.google.com/search?as_q=#{query}&lr=lang_"),
  })
  i = 0
  search.each do |result|
    feedback.add_item({
      :uid      => "suggest #{query}",
      :title    => result.title,
      :subtitle => result.uri,
      :arg      => result.uri
    })
    i = 1 + i
    break if i > 20
  end


  puts feedback.to_xml
end

if __FILE__ == $PROGRAM_NAME

  query = ARGV.join(" ")

  generate_feedback(query)
end


