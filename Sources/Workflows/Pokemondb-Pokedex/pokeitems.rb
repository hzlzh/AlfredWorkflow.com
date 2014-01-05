require 'yaml'
require File.join(File.dirname(__FILE__), 'alfred_feedback.rb')

class Pokeitems
  FILE_DATA = YAML.load_file(File.join(File.dirname(__FILE__), 'items.yml'))

  def self.search(string)

	matches = FILE_DATA.select do |name, data|
		name.downcase.include? string.downcase
	end

    feedback = Feedback.new

    matches.each do |name, data|

    	n = name.delete(' ')
    	imageName = n.downcase

     	feedback.add_item({
			:title => "#{name}",
			:subtitle => data['description'],
			:autocomplete => "#{name}",
			:arg => name,
			:icon => {:type => "filetype", :name => "items_img/#{imageName}.png"}
      })

	end		

    puts feedback.to_xml

  end
end

Pokeitems.search ARGV.join.strip