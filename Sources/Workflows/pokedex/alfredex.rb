require 'yaml'
require File.join(File.dirname(__FILE__), 'alfred_feedback.rb')

class Alfredex
  FILE_DATA = YAML.load_file(File.join(File.dirname(__FILE__), 'pokemon.yml'))

  def self.search(string)
    matches = nil

    if string =~ /^[0-9]+$/ # numeric string, check pokemon number
      matches = FILE_DATA.select do |name, data|
        data['number'].to_i == string.to_i
      end
    else # check for name
      matches = FILE_DATA.select do |name, data|
        name.downcase.include? string.downcase
      end
      matches = matches.sort_by do |k,v|
        k.downcase[0..string.length-1] == string.downcase ? 0 : 1
      end
    end

    feedback = Feedback.new

    matches.each do |name, data|
      feedback.add_item({
        :title => "##{data['number'].to_i} #{name}",
        :subtitle => data['description'],
        :arg => data['url_name'],
        :uid => data['number'],
        :icon => {:type => "filetype", :name => "pokemon_sprites/#{data['number']}.png"}
      })
    end

    puts feedback.to_xml
  end
end

Alfredex.search ARGV.join.strip
