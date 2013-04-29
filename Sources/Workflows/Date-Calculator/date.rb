# query
q = ARGV[0] || ""


# format given by query?
if q =~ /"/
  format = q.scan(/"([^"]+)"/).last[0]
  unless format.empty? || format =~ /%/
    format.gsub!(/([aAbBcdeHIjlmMpPSwWyYZ])/i, '%\1')
  end

# read format from file
else
  filename_old = 'format.txt'
  filename_new = 'format2.txt'

  # did migration from PHP's 'date' to strftime already happen?
  if File.exist?(filename_new)
    file   = File.open(filename_new, "r")
    format = file.read.strip
    file.close
  
  # do migration
  else
    old_file   = File.open(filename_old, "r")
    format     = old_file.read.strip
    old_file.close

    replacements = {
      :a => '%P',
      :A => '%p',
      :B => '',   # swatch internet time doesn't exist in strftime
      :c => '',
      :d => '%d',
      :D => '%a',
      :e => '',   # timezone identifier does not exist in strftime
      :F => '%B',
      :g => '%l',
      :G => '',   # 24-h clock without leading zeros doesn't exist in strftime
      :h => '%I',
      :H => '%H',
      :i => '%M',
      :I => '',   # daylight savings time boolean does not exist in strftime
      :j => '%e',
      :l => '%A',
      :L => '',   # leap year or not doesn't exist in strftime
      :m => '%m',
      :M => '%b',
      :n => '%m', # month wothout leading zeros doesn't exist in strftime
      :N => '',   # day of week 1-7 doesn't exist in strftime
      :o => '%Y', # not completely compatatible to ISO-8601 but ok
      :O => '',   # diff to Greenwich does not exist in strftime
      :P => '',   # diff to Greenwich does not exist in strftime
      :r => '%c', # doesn't match RFC 2822 exactly but ok
      :S => '',   # endings like 'st', 'nd', 'rd', 'th' do not exist in strftime
      :s => '%S',
      :t => '',   # amount of days a month has doesn't exist in strftime
      :T => '%Z',
      :u => '',   # microsecond does not exist in strftime
      :U => '',   # seconds since unix epoch does not exist in strftime
      :w => '%w',
      :W => '%W', # 1-54 will become 0-53
      :y => '%y',
      :Y => '%Y',
      :z => '%j', # 0-365 will become 1-366 in strftime
      :Z => ''    # timezone offset does not exist in strftime
    }

    new_format = ''
    format.split("").each do |c|
        new_format += replacements[c.to_sym] || c
    end

    File.open(filename_new, 'w') {|f| f.write(new_format) }
    File.delete(filename_old)
    format = new_format
  end
end


# convert to unix 'date' params
params = []
q.split(' ').each do |s|
  quantifier = s.to_i
  
  if s =~ /\d+y/
    unit_symbol = "y"
  elsif s =~ /\d+m/ && (s =~ /\d+min/).nil?
    unit_symbol = "m"
  elsif s =~ /\d+w/
    unit_symbol = "w"
  elsif s =~ /\d+d/
    unit_symbol = "d"
  elsif s =~ /\d+h/
    unit_symbol = "H"
  elsif s =~ /\d+min/
    unit_symbol = "M"
  elsif s =~ /\d+s/
    unit_symbol = "S"
  else
    next
  end

  params << '-v' + (quantifier > -1 ? '+' : '') + quantifier.to_s + unit_symbol
end


# return result
ts_formatted = `echo $(date #{params.join(' ')} "+#{format}")`.strip
puts <<ENDS_HERE
<items>
  <item uid="date" arg="#{ts_formatted}">
    <title>#{ts_formatted}</title>
    <subtitle>Press "Enter" to copy "#{ts_formatted}" to clipboard</subtitle>
    <icon>icon.png</icon>
  </item>
</items>
ENDS_HERE