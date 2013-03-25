#!/usr/bin/env ruby
# encoding: utf-8

# ============== = ===========================================================
# Description    : Alfred 2 Google Suggest Workflow
# Author         : Zhao Cai <caizhaoff@gmail.com>
# HomePage       : https://github.com/zhaocai/
# Version        : 0.1
# Date Created   : Sun 10 Mar 2013 09:59:48 PM EDT
# Last Modified  : Tue 19 Mar 2013 05:29:07 AM EDT
# Tag            : [ ruby, alfred, workflow ]
# Copyright      : © 2013 by Zhao Cai,
#                  Released under current GPL license.
# ============== = ===========================================================

($LOAD_PATH << File.expand_path("..", __FILE__)).uniq!

require "rubygems"
require "bundle/bundler/setup"


require 'lib/google_suggest'
require "lib/alfred_feedback.rb"





def generate_feedback(query)

  gs = GoogleSuggest.new
  feedback = Feedback.new

  feedback.add_item({
    :title    => "Search '#{query}'",
    :subtitle => "Open brower for more results.",
    :arg      => query,
  })

  icon = {:type => "default", :name => "icon.png"}
  gs.suggest_for(query).each do |s|
    feedback.add_item({
      :title              => s['suggestion']                        ,
      :subtitle           => "Search Google for #{s['suggestion']}" ,
      :arg                => s['suggestion']                        ,
      :icon               => icon                                   ,
    })
  end

  puts feedback.to_xml
end

if __FILE__ == $PROGRAM_NAME

  query = ARGV.join(" ")
  generate_feedback(query)
end


