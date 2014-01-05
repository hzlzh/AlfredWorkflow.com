require 'yaml'

class ArgParser
  POKEMON_DATA = YAML.load_file(File.join(File.dirname(__FILE__), 'pokemon.yml'))
  TYPES_DATA = YAML.load_file(File.join(File.dirname(__FILE__), 'types.yml'))

  def self.search(string)

	s = string.split(',')

		matches = POKEMON_DATA.select do |name, data|
			name.downcase == s[0].downcase
		end

		if matches.count == 0
			matches = TYPES_DATA.select do |name|
				name.downcase == s[0].downcase
			end

			if matches.count != 0

				`osascript ./alfred.scpt #{string}`
			end
		else
			string.split(",").each {|p| `open http://www.pokemondb.net/pokedex/#{p}`}
		end
	end
end

ArgParser.search ARGV.join.strip
