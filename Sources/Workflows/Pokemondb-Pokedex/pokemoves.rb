require 'yaml'
require File.join(File.dirname(__FILE__), 'alfred_feedback.rb')

class String
    def is_number?
       !!(self =~ /^[-+]?[0-9]+$/)
    end
end

class Pokemoves
  FILE_DATA = YAML.load_file(File.join(File.dirname(__FILE__), 'moves.yml'))

  def self.search(string)

  	matches = nil

  	if string =~ /\d/
		s = string.scan(/\d+|\D+/)
		
		if s[1].length == 1
			s[1] = "0" + s[1]
		end
		
		string = s[0].upcase + s[1]
	end

  	if string.include? "TM" or string.include? "HM"
        matches = FILE_DATA.select do |name, data|
          data['tm'] == string
        end

    else
	
		matches = FILE_DATA.select do |name, data|
		      name.downcase.include? string.downcase
		    end
	end

	    feedback = Feedback.new

	    matches.each do |name, data|

	      if data['tm']
				feedback.add_item({
							:title => "#{name} (#{data['tm']})",
							:autocomplete => "#{name}",
							:arg => name,
							:icon => {:type => "filetype", :name => "types_img/#{data['type']}.png"}
				      })
			else
				feedback.add_item({
							:title => "#{name}",
							:autocomplete => "#{name}",
							:arg => name,
							:icon => {:type => "filetype", :name => "types_img/#{data['type']}.png"}
				      })
			end
			
			moveStats = ''
			
			if data['power'].is_number?
				moveStats += "Power: #{data['power']}"
			end
			
			if data['accuracy'].is_number?
			
				if data['power'].is_number?
					moveStats += ", "
				end
				moveStats += "Acc.: #{data['accuracy']}"
			end
			
			if data['pp'].is_number?
			
				if data['accuracy'].is_number?
					moveStats += ", "
				end
				moveStats += "PP: #{data['pp']}"
			end
			
			if data['probability'].is_number?
			
				if data['pp'].is_number?
					moveStats += ", "
				end
				moveStats += "Prob.: #{data['probability']}%"
			end

			if data['description'] != ''

		      feedback.add_item({
					:title => data['description'],
					:subtitle => "#{moveStats}",
					:icon => {:type => "filetype", :name => "categories_img/#{data['category']}.png"}
		      })
		  else

		  	feedback.add_item({
					:title => "#{moveStats}",
					:icon => {:type => "filetype", :name => "categories_img/#{data['category']}.png"}
		      })

		  end
		  	
	end

    puts feedback.to_xml

  end
end

Pokemoves.search ARGV.join.strip