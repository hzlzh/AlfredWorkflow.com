q   = ARGV[0]
t   = Time.now
out = ''


# custom
out += "<item uid=\"date_format_0\""
out += " arg=\"#{q}\"" unless q.empty?
out += ">"
out += "<title>"
if q.empty?
  out += "Insert format or choose from suggestions below"
  out += "</title>"
  out += "<subtitle>"
  out += "Press \"Enter\" to view format options on php.net"
  out += "</subtitle>"
else
  out += `echo "<?php echo date('#{q}', #{t.to_i});" | php`
  out += "</title>"
  out += "<subtitle>"
  out += "Format: #{q}"
  out += "</subtitle>"
end
out += "<icon>icon.png</icon>"
out += "</item>\n"


# defaults
[
  "F j, Y – H:i",
  "F j, Y – H:i:s",
  "d.m.Y, H:i",
  "d.m.Y, H:i:s",
  "Ymd_Hi",
  "Ymd_His",
  "ymd_Hi",
  "ymd_His"
].each_with_index do |format, i|
  out += "<item uid=\"date_format_#{i+1}\" arg=\"#{format}\">"
  out += "<title>#{`echo "<?php echo date('#{format}', #{t.to_i});" | php`}</title>"
  out += "<subtitle>Format: #{format}</subtitle>"
  out += "<icon>icon.png</icon>"
  out += "</item>\n"
end


# return results
puts "<items>#{out}</items>"