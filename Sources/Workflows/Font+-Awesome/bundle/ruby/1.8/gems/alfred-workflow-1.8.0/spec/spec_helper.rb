$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])

require "rspec"
require 'facets/string'
require 'fileutils'


require "alfred"

RSpec.configure do |c|
  c.color_enabled = true

  # Use color not only in STDOUT but also in pagers and files
  c.tty = true

  c.formatter = :documentation # :progress, :html, :textmate

  c.mock_with :rspec
end

class String
  def strip_heredoc
    indent = scan(/^[ \t]*(?=\S)/).min.size || 0
    gsub(/^[ \t]{#{indent}}/, '')
  end
end

$rspec_dir = Dir.pwd
$workflow_dir = 'test/workflow/'
def setup_workflow
  FileUtils.mkdir_p($workflow_dir)
  Dir.chdir($workflow_dir)
end

def reset_workflow
  Dir.chdir($rspec_dir)
end

def compare_xml(expected_xml_data, feedback_xml_data)
  item_elements = %w{title subtitle icon}
  item_attributes = %w{uid arg autocomplete}

  expected_xml = REXML::Document.new(expected_xml_data)
  feedback_xml = REXML::Document.new(feedback_xml_data)

  expected_item = expected_xml.get_elements('/items/item')[0]
  feedback_item = feedback_xml.get_elements('/items/item')[0]

  item_elements.each { |i|
    unless expected_item.elements[i].text.eql? feedback_item.elements[i].text
      return false
    end
  }
  item_attributes.each { |i|
    unless expected_item.attributes[i].eql? feedback_item.attributes[i]
      return false
    end
  }
  true
end
