#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require 'bundle/bundler/setup'
require 'alfred'
require 'oj'
require 'open-uri'

require File.join(File.dirname(__FILE__), 'lib/alfred_workflow')
require File.join(File.dirname(__FILE__), 'lib/hatmaker')
require File.join(File.dirname(__FILE__), 'lib/hatmaker/alfred')
require File.join(File.dirname(__FILE__), 'lib/hatmaker/alfred/workflow')
require File.join(File.dirname(__FILE__), 'lib/hatmaker/alfred/yaml_end')
require File.join(File.dirname(__FILE__), 'lib/hatmaker/workflow')

def search(query, feedback)
  workflows = Hatmaker::Workflow.search(query)
  workflows.each do |workflow|
    feedback.add_item(
      :uid      => workflow.uid,
      :title    => workflow.name,
      :subtitle => workflow.description,
      :arg      => workflow.to_json
    )
  end
end

def install(json, feedback)
  begin
    workflow = Oj.load(json)
    workflow.download { |workflow| workflow.install }
  rescue OpenURI::HTTPError => ex
    puts "Error while downloading #{workflow.name}, please try again later."
  end
end

def outdated(feedback)
  Hatmaker::Alfred::Workflow.all.each do |installed_workflow|
    if installed_workflow.outdated?
      new_release = installed_workflow.last_release

      feedback.add_item(
        :uid      => new_release.uid,
        :title    => new_release.name,
        :subtitle => "v#{new_release.version} by #{new_release.author}",
        :arg      => new_release.to_json
      )
    end
  end
end

Alfred.with_friendly_error do |alfred|
  alfred.with_rescue_feedback = true
  feedback = alfred.feedback

  command   = ARGV[0]
  arguments = ARGV[1]

  case command
  when /search/
    search arguments, feedback
  when /install/
    install arguments, feedback
  when /outdated/
    outdated feedback
  end

  if feedback.items.none?
    feedback.add_item(
      :uid      => 'nothingfound',
      :title    => arguments ? "No workflows found with '#{arguments}'" : 'All workflows are up to date!',
      :valid    => 'no'
    )
  end

  puts feedback.to_xml if command != 'install'
end

