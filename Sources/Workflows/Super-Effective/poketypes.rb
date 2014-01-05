require 'yaml'
require File.join(File.dirname(__FILE__), 'alfred_feedback.rb')

class Poketypes
  FILE_DATA = YAML.load_file(File.join(File.dirname(__FILE__), 'types.yml'))

  def self.search(string)

	matches = nil

	if string =~ /[\/,\,]/

		s = string.delete(' ')
		types = s.downcase.split(',')	

		matches = FILE_DATA.select do |name, data|
	      types.include? name.downcase
	   end
		
		supereffectiveArray = []
		noneffectiveArray = []
		immuneTypes = []
		
		typeNames = []
		
		matches.each do |name, data|
			
			typeNames.push(name)
			
			s = data['supereffective-from'].delete(' ')
			types = s.split(',')
			supereffectiveArray.push(*types)
			
			s = data['noneffective-from'].delete(' ')
			nonTypes = s.split(',')
			noneffectiveArray.push(*nonTypes)
			
			if data['immune-to']
				s = data['immune-to'].delete(' ')
				immune = s.split(',')
				immuneTypes.push(*immune)
			end
			
		end
		
		supereffectiveTypes = supereffectiveArray.dup
		noneffectiveTypes = noneffectiveArray.dup
		
		supereffectiveArray.each do |t1|
		
			noneffectiveArray.each do |t2|
			
				if t2 == 'None'
					noneffectiveTypes.delete(t2)
				end
			
				if t1 == t2
					supereffectiveTypes.delete(t1)
				end
			end
			
			immuneTypes.each do |t3|
						
				if t1 == t3
					supereffectiveTypes.delete(t1)
				end
			end
		end
		
		dup, supereffectiveTypes = supereffectiveTypes.partition{|element| supereffectiveTypes.count(element) > 1 }
		fourTimesSupereffective = dup.uniq
		
		dup, noneffectiveTypes = noneffectiveTypes.partition{|element| noneffectiveTypes.count(element) > 1 }
		fourTimesNoneffective = dup.uniq
		
		feedback = Feedback.new
		
		feedback.add_item({
		        :title => "#{typeNames[0]} | #{typeNames[1]} type",
		        :arg => "#{typeNames[0]}",
		        :icon => {:type => "filetype", :name => "types_img/#{typeNames[0]}-#{typeNames[1]}.gif"}
		      })
		
		feedback.add_item({
		        :title => "#{noneffectiveTypes.uniq.join(', ')}",
		        :icon => {:type => "filetype", :name => "damage_img/half-from.png"}
		      })
		
		feedback.add_item({
		        :title => "#{supereffectiveTypes.uniq.join(', ')}",
		        :icon => {:type => "filetype", :name => "damage_img/2x-from.png"}
		      })
		
		feedback.add_item({
		        :title => "#{fourTimesNoneffective.join(', ')}",
		        :icon => {:type => "filetype", :name => "damage_img/quarter-from.png"}
		      })
		
		feedback.add_item({
		        :title => "#{fourTimesSupereffective.join(', ')}",
		        :icon => {:type => "filetype", :name => "damage_img/4x-from.png"}
		      })
		
		feedback.add_item({
		        :title => "#{immuneTypes.uniq.join(', ')}",
		        :icon => {:type => "filetype", :name => "damage_img/immune-to.png"}
		      })
		
		
		puts feedback.to_xml
		
	else
	
	matches = FILE_DATA.select do |name, data|
	      name.downcase.include? string.downcase
	    end

    feedback = Feedback.new

    matches.each do |name, data|
      feedback.add_item({
			:title => "#{name} type",
			:autocomplete => "#{name}",
			:arg => data['url_name'],
			:icon => {:type => "filetype", :name => "types_img/#{name}-.gif"}
      })

      feedback.add_item({
        :title => data['supereffective'],
        :arg => data['url_name'],
        :icon => {:type => "filetype", :name => "damage_img/2x.png"}
      })

      feedback.add_item({
        :title => data['noneffective'],
        :arg => data['url_name'],
        :icon => {:type => "filetype", :name => "damage_img/half.png"}
      })

      feedback.add_item({
        :title => data['noneffective-from'],
        :arg => data['url_name'],
        :icon => {:type => "filetype", :name => "damage_img/half-from.png"}
      })

      feedback.add_item({
        :title => data['supereffective-from'],
        :arg => data['url_name'],
        :icon => {:type => "filetype", :name => "damage_img/2x-from.png"}
      })

      if data['immune-to']

        feedback.add_item({
          :title => data['immune-to'],
          :arg => data['url_name'],
          :icon => {:type => "filetype", :name => "damage_img/immune-to.png"}
        })

      end

      if data['cant-damage']

        feedback.add_item({
          :title => data['cant-damage'],
          :arg => data['url_name'],
          :icon => {:type => "filetype", :name => "damage_img/cant-damage.png"}
        })

      end
    end

    puts feedback.to_xml

	end
  end
end

Poketypes.search ARGV.join.strip
