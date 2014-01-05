require 'yaml'

class ArgParser
  POKEMON_DATA = YAML.load_file(File.join(File.dirname(__FILE__), 'pokemon.yml'))
  TYPES_DATA = YAML.load_file(File.join(File.dirname(__FILE__), 'types.yml'))
  MOVES_DATA = YAML.load_file(File.join(File.dirname(__FILE__), 'moves.yml'))

  def self.search(string)

		s = string.split(',')

		numbers = []

		matches = POKEMON_DATA.select do |name, data|
			if s.include? name.downcase
				numbers.push(data['number'])
				true
			end
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
					string = string.delete(' ')
					`open http://www.serebii.net/attackdex-xy/#{string.downcase}.shtml`
				end
			else
				`open http://www.serebii.net/pokedex-xy/#{string.downcase}.shtml`
			end
		else
			string = numbers.join(',')
			string.split(",").each {|p| `open http://www.serebii.net/pokedex-xy/#{p}.shtml`}
		end
	end
end

ArgParser.search ARGV.join.strip
