require 'yaml'

class ArgParser
  POKEMON_DATA = YAML.load_file(File.join(File.dirname(__FILE__), 'pokemon.yml'))
  TYPES_DATA = YAML.load_file(File.join(File.dirname(__FILE__), 'types.yml'))
  MOVES_DATA = YAML.load_file(File.join(File.dirname(__FILE__), 'moves.yml'))

	def self.search(string)

		s = string.split(',')

		matches = POKEMON_DATA.select do |name, data|
			name.downcase == s[0].downcase
		end

		if matches.count == 0
			matches = TYPES_DATA.select do |name|
				name.downcase == s[0].downcase
			end

			if matches.count == 0
				matches = MOVES_DATA.select do |name|
					name.downcase == s[0].downcase
				end

				if matches.count != 0
					s = string.split(' ')
			    	dashedName = s.join('-')
					`open http://pokemondb.net/move/#{dashedName.downcase}`
				end
			else
				`open http://pokemondb.net/type/#{string}`
			end
		else
			string.split(",").each {|p| `open http://www.pokemondb.net/pokedex/#{p}`}
		end
	end
end

ArgParser.search ARGV.join.strip
