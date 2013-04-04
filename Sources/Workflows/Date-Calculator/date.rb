# helpers
def get_time_as_arr(ts)
  Time.at(ts).to_a
end

def get_time_from_arr(arr)
  Time.local(arr[5], arr[4], arr[3], arr[2], arr[1], arr[0]).to_i
end

def add_year(ts, num_year)
  arr = get_time_as_arr(ts)
  arr[5] += num_year
  get_time_from_arr(arr)
end

def add_month(ts, num_month)
  arr   = get_time_as_arr(ts)
  month = arr[4] + num_month - 1 # make 0-based
  year  = arr[5]
  
  unless month.between?(0, 11)
    if month < 0
      year -= (month.abs / 12) + 1
    else  
      year += month / 12
    end
    month = month % 12
  end

  max_days  = [31, (year % 4 == 0) ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  arr[3]
  if arr[3] > max_days[month]
    arr[3] = max_days[month]
  end

  arr[4] = month + 1
  arr[5] = year
  get_time_from_arr(arr)
end


# query
q = ARGV[0] || ""


# date format
if q =~ /"/
  format = q.scan(/"([^"]+)"/).last[0]
else
  file   = File.open('format.txt', "r")
  format = file.read
  file.close
end


# set some vars, make them 0-based
ts = Time.now.to_i


# calculate time units
q.split(' ').each do |s|
  quantifier = s.to_i
  if s =~ /\d+y/
    ts = add_year(ts, quantifier)
  elsif s =~ /\d+m/ && (s =~ /\d+min/).nil?
    ts = add_month(ts, quantifier)
  elsif s =~ /\d+w/
    ts += quantifier * 7*24*60*60
  elsif s =~ /\d+d/
    ts += quantifier * 24*60*60
  elsif s =~ /\d+h/
    ts += quantifier * 60*60
  elsif s =~ /\d+min/
    ts += quantifier * 60
  elsif s =~ /\d+s/
    ts += quantifier
  else
    next
  end
end


# format time
ts_formatted = `echo "<?php echo date('#{format}', #{ts});" | php`.strip
  

# return result
puts <<ENDS_HERE
<items>
  <item uid="date" arg="#{ts_formatted}">
    <title>#{ts_formatted}</title>
    <subtitle>Press "Enter" to copy "#{ts_formatted}" to clipboard</subtitle>
    <icon>icon.png</icon>
  </item>
</items>
ENDS_HERE