#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require 'bundle/bundler/setup'
require 'alfred'

def generate_feedback(alfred, query)
  feedback = alfred.feedback
  queries  = query.split
  icons    = Dir.glob(File.expand_path('./icon-*.png')).map { |path|
               md = /\/icon-(.+)\.png/.match(path)
               (md && md[1]) ? md[1] : nil
             }.compact.sort

  queries.each do |q|
    icons.reject! { |i| i.index(q.downcase) ? false : true }  # select!...
  end

  icons.each do |icon|
    feedback.add_item({
      :uid      => '',
      :title    => icon,
      :subtitle => "Copy to clipboard: icon-#{icon}",
      :arg      => icon,
      :icon     => { :type => 'default', :name => "icon-#{icon}.png" },
      :valid    => 'yes',
    })
  end

  puts feedback.to_alfred
end

Alfred.with_friendly_error do |alfred|
  alfred.with_rescue_feedback = true
  query = ARGV.join(' ').strip
  generate_feedback(alfred, query)
end

