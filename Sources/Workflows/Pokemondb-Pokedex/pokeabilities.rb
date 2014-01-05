require 'yaml'
require File.join(File.dirname(__FILE__), 'alfred_feedback.rb')

class Pokeabilities
  FILE_DATA = YAML.load_file(File.join(File.dirname(__FILE__), 'abilities.yml'))

  def self.search(string)

	matches = FILE_DATA.select do |name, data|
	      name.downcase.include? string.downcase
	    end

    feedback = Feedback.new

    matches.each do |name, data|

      feedback.add_item({
						:title => "#{name}",
						:subtitle => data['description'],
						:autocomplete => "#{name}",
						:arg => data['url_name'],
						:icon => {:type => "filetype", :name => "icon.png"}
			      })
		  	
	end

    puts feedback.to_xml

  end
end

Pokeabilities.search ARGV.join.strip