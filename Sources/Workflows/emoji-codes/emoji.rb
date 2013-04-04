def item_xml(options = {})
  <<-ITEM
  <item arg="#{options[:arg]}" uid="#{options[:uid]}">
    <title>#{options[:title]}</title>
    <icon>#{options[:path]}</icon>
  </item>
  ITEM
end

images_path = File.expand_path('../images/emoji', __FILE__)

names = Dir["#{images_path}/*.png"].sort.map { |fn| File.basename(fn, '.png') }

query = Regexp.escape(ARGV.first)

items = names.grep(/#{query}/).map do |elem|
  path = File.join(images_path, "#{elem}.png")
  emoji_code = ":#{elem}:"

  item_xml({ :arg => emoji_code, :uid => elem, :path => path, :title => emoji_code })
end.join

output = "<?xml version='1.0'?>\n<items>\n#{items}</items>"

puts output
