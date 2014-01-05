require 'yaml'
require File.join(File.dirname(__FILE__), 'alfred_feedback.rb')

class String
    def is_number?
       !!(self =~ /^[-+]?[0-9]+$/)
    end
end

class Alfredex
	FILE_DATA = YAML.load_file(File.join(File.dirname(__FILE__), 'pokemon.yml'))
	POKEMOVES_DATA = YAML.load_file(File.join(File.dirname(__FILE__), 'pokemoves.yml'))
	MOVES_DATA = YAML.load_file(File.join(File.dirname(__FILE__), 'moves.yml'))
	EVOLUTIONS_DATA = YAML.load_file(File.join(File.dirname(__FILE__), 'evolutions.yml'))

	def self.createMoveFeedback(name, lvl, data, feedback)
		
		subtitle = ''
		
		if lvl
			subtitle += "Level: #{lvl}"
		end

		    if data['tm']
				feedback.add_item({
							:title => "#{name} (#{data['tm']})",
							:subtitle => subtitle,
							:autocomplete => "#{name}",
							:arg => name,
							:icon => {:type => "filetype", :name => "types_img/#{data['type']}.png"}
				      })
			else
				feedback.add_item({
							:title => "#{name}",
							:subtitle => subtitle,
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
		
		return feedback
	
	end

  def self.search(string)

    matches = nil
    language = 'en'

    if string =~ /[\/,\,]/ # contains separators, look up multiple
      string = string.delete(' ')
      mons = string.split(/[\/,\,]/).map{|n| n.strip.downcase }
      dashed_mons = mons.select{|m| m =~ /\-/}

      matches = FILE_DATA.select do |name, data|
        if mons.include? name.downcase
          true
        elsif dashed_mons.length > 0 # contains dash and doesn't match, split
          dashed_mons.any?{|m| m.split('-')[0] == name.downcase }
        end
      end

      # maximum 10 lookups, don't flood the user with tabs
      matches = matches.to_a[0..9]

      feedback = Feedback.new
      feedback.add_item({
        :title => "Find Multiple Pokemon",
        :subtitle => matches.map{|m| m[0]}.join(', '),
        :arg => matches.map{|m| m[1]['url_name'] }.join(","),
        :uid => matches.map{|m| m[1]['number'] }.join(','),
        :icon => {:type => "filetype", :name => "icon.png"}
      })

      puts feedback.to_xml

     else

     	s = string.split(' ')
	    string = s[0]
	    info = s[1]
	    filter = s[2]

		if info == 'evo'
					
			matches = EVOLUTIONS_DATA.select do |name, data|
				name.downcase == string.downcase
			end
			
			feedback = Feedback.new
			
			matches.each do |name, data|
				
				if data.count > 0
					data.each_with_index do |item, index|
						
						if index % 2 == 0
						
							pokeMatches = FILE_DATA.select do |name, data|
						          name.downcase == item.downcase
						        end
					
							number = 0
							url_name = ''
				
							pokeMatches.each do |name, data|
								number = data['number']
								url_name = data['url_name']
							end
						
							feedback.add_item({
					          :title => "##{number.to_i} #{item}",
					          :autocomplete => name,
					          :arg => url_name,
					          :icon => {:type => "filetype", :name => "pokemon_sprites/#{number}.png"}
					        })
						else
						
							feedback.add_item({
						        :title => item,
						        :icon => {:type => "filetype", :name => "arrow.png"}
						      })
						end
					end
				else
					feedback.add_item({
			        :title => "This Pokémon doesn't evolve.",
			        :icon => {:type => "filetype", :name => "icon.png"}
			      })
				end
			end
			
			puts feedback.to_xml

		elsif info == "lvl"
			
			matches = POKEMOVES_DATA.select do |name, data|
				name.downcase.include? string.downcase
			end
			
			feedback = Feedback.new

			matches.each do |name, data|
				
				data['Level Up'].each do |move, lvl|
				
					if filter
				      movesMatches = MOVES_DATA.select do |name, data|
							name.downcase == move.downcase and data['type'].downcase.include? filter.downcase
						end
					else
						movesMatches = MOVES_DATA.select do |name, data|
							name.downcase == move.downcase
						end
					end

					movesMatches.each do |name, data|
						feedback = self.createMoveFeedback(name, lvl, data, feedback)
					end
					
				end
			end
			
			if feedback.to_xml == '<items/>'

				feedback.add_item({
		        :title => "No results found.",
		        :icon => {:type => "filetype", :name => "icon.png"}
		      })

			end

			puts feedback.to_xml
			
		elsif info == "hm"
				
				matches = POKEMOVES_DATA.select do |name, data|
					name.downcase.include? string.downcase
				end
				
				feedback = Feedback.new
				lvl = nil
				
				matches.each do |name, data|
				
					if data['HM'].count > 0
						
						data['HM'].each do |move|
						
							movesMatches = MOVES_DATA.select do |name, data|
								name.downcase == move.downcase
							end
										
							movesMatches.each do |name, data|
								feedback = self.createMoveFeedback(name, lvl, data, feedback)
							end
						end
					end
				end

				if feedback.to_xml == '<items/>'

					feedback.add_item({
			        :title => "No results found.",
			        :icon => {:type => "filetype", :name => "icon.png"}
			      })

				end
				
				puts feedback.to_xml
				
		elsif info == "tm"
				
				matches = POKEMOVES_DATA.select do |name, data|
					name.downcase.include? string.downcase
				end
				
				feedback = Feedback.new
				lvl = nil

				matches.each do |name, data|
					
					if data['TM'].count > 0
					
						data['TM'].each do |move|
							
							if filter
						      movesMatches = MOVES_DATA.select do |name, data|
									name.downcase == move.downcase and data['type'].downcase.include? filter.downcase
								end
							else
								movesMatches = MOVES_DATA.select do |name, data|
									name.downcase == move.downcase
								end
							end
										
							movesMatches.each do |name, data|
								feedback = self.createMoveFeedback(name, lvl, data, feedback)
							end
						end
					end
				end

				if feedback.to_xml == '<items/>'

					feedback.add_item({
			        :title => "No results found.",
			        :icon => {:type => "filetype", :name => "icon.png"}
			      })

				end
				
				puts feedback.to_xml
				
		elsif info == "egg"
				
				matches = POKEMOVES_DATA.select do |name, data|
					name.downcase.include? string.downcase
				end
				
				feedback = Feedback.new
				lvl = nil
				
				matches.each do |name, data|
				
					if data['Egg Moves'].count > 0
					
						data['Egg Moves'].each do |move|
						
					      	if filter
						      movesMatches = MOVES_DATA.select do |name, data|
									name.downcase == move.downcase and data['type'].downcase.include? filter.downcase
								end
							else
								movesMatches = MOVES_DATA.select do |name, data|
									name.downcase == move.downcase
								end
							end
										
							movesMatches.each do |name, data|
								feedback = self.createMoveFeedback(name, lvl, data, feedback)
							end
						end
					end
				end

				if feedback.to_xml == '<items/>'

					feedback.add_item({
			        :title => "No results found.",
			        :icon => {:type => "filetype", :name => "icon.png"}
			      })

				end
				
				puts feedback.to_xml

		else # single pokemon

	      if string =~ /^[0-9]+$/ # numeric string, check pokemon number
	        matches = FILE_DATA.select do |name, data|
	          data['number'].to_i == string.to_i
	        end
	      else # check for name
	        matches = FILE_DATA.select do |name, data|
	        	if name.downcase.include? string.downcase
	        		language = 'en'
	        		true
	        	elsif data['Romaji'].downcase.include? string.downcase
	        		language = 'jp'
	        		true
	        	end
	        end
	        matches = matches.sort_by do |k,v|
	          k.downcase[0..string.length-1] == string.downcase ? 0 : 1
	        end
	      end

	      feedback = Feedback.new
	      matches.each do |name, data|
	        
	        if language == 'en'
		        feedback.add_item({
		          :title => "##{data['number'].to_i} #{name}",
		          :subtitle => data['description'],
		          :autocomplete => name,
		          :arg => data['url_name'],
		          :icon => {:type => "filetype", :name => "pokemon_sprites/#{data['number']}.png"}
		        })
		    elsif language == 'jp'
		    	feedback.add_item({
		          :title => "##{data['number'].to_i} #{data['Kana']}",
		          :subtitle => data['description'],
		          :autocomplete => name,
		          :arg => data['url_name'],
		          :icon => {:type => "filetype", :name => "pokemon_sprites/#{data['number']}.png"}
		        })
		    end

	        if data['secondType']
	          feedback.add_item({
	            :title => "#{data['firstType']} | #{data['secondType']}",
	            :arg => "#{data['firstType']}, #{data['secondType']}",
	            :icon => {:type => "filetype", :name => "types_img/dual-types/#{data['firstType']}-#{data['secondType']}.gif"}
	            })
	        else
	          feedback.add_item({
	            :title => data['firstType'],
	            :arg => data['firstType'],
	            :icon => {:type => "filetype", :name => "types_img/#{data['firstType']}.png"}
	            })
	        end

	        if data['firstMegaTypeY']

	          if data['secondMegaType']
	            feedback.add_item({
	              :title => "#{data['firstMegaType']} | #{data['secondMegaType']}",
	              :subtitle => "Mega #{name} X",
	              :arg => "#{data['firstMegaType']}, #{data['secondMegaType']}",
	              :icon => {:type => "filetype", :name => "types_img/dual-types/#{data['firstMegaType']}-#{data['secondMegaType']}.gif"}
	              })
	          else
	            feedback.add_item({
	              :title => data['firstMegaType'],
	              :subtitle => "Mega #{name} X",
	              :arg => data['firstMegaType'],
	              :icon => {:type => "filetype", :name => "types_img/#{data['firstMegaType']}.png"}
	              })
	          end

	          if data['secondMegaTypeY']
	          feedback.add_item({
	            :title => "#{data['firstMegaTypeY']} | #{data['secondMegaTypeY']}",
	            :subtitle => "Mega #{name} Y",
	            :arg => "#{data['firstMegaTypeY']}, #{data['secondMegaTypeY']}",
	            :icon => {:type => "filetype", :name => "types_img/dual-types/#{data['firstMegaTypeY']}-#{data['secondMegaTypeY']}.gif"}
	            })

	        else
	          feedback.add_item({
	            :title => data['firstMegaTypeY'],
	            :subtitle => "Mega #{name} Y",
	            :arg => data['firstMegaTypeY'],
	            :icon => {:type => "filetype", :name => "types_img/#{data['firstMegaTypeY']}.png"}
	            })
	        end

	        else

	          if data['secondMegaType']
	            feedback.add_item({
	              :title => "#{data['firstMegaType']} | #{data['secondMegaType']}",
	              :subtitle => "Mega #{name}",
	              :arg => "#{data['firstMegaType']}, #{data['secondMegaType']}",
	              :icon => {:type => "filetype", :name => "types_img/dual-types/#{data['firstMegaType']}-#{data['secondMegaType']}.gif"}
	              })

	          elsif data['firstMegaType']
	            feedback.add_item({
	              :title => data['firstMegaType'],
	              :subtitle => "Mega #{name}",
	              :arg => data['firstMegaType'],
	              :icon => {:type => "filetype", :name => "types_img/#{data['firstMegaType']}.png"}
	              })
	          end
	        end
	      end

	      puts feedback.to_xml
	   	end
	  end
	end
end

Alfredex.search ARGV.join.strip
