# encoding: utf-8
q = ARGV[0]
unless q.empty? || q =~ /%/
  q = q.gsub(/([aAbBcdeHIjlmMpPSwWyYZ])/i, '%\1')
end


# custom
out = ''
out += "<item uid=\"date_format_0\""
out += " arg=\"#{q}\"" unless q.empty?
out += ">"
out += "<title>"
if q.empty?
  out += "Insert format or choose from suggestions below"
  out += "</title>"
  out += "<subtitle>"
  out += "Press \"Enter\" to view format options on strfti.me"
  out += "</subtitle>"
else
  out += `echo $(date "+#{q}")`.strip
  out += "</title>"
  out += "<subtitle>"
  out += "Format: #{q}"
  out += "</subtitle>"
end
out += "<icon>icon.png</icon>"
out += "</item>\n"


# defaults
[
  "%B %e, %Y  %H:%M",
  "%B %e, %Y  %H:%M:%S",
  "%d.%m.%Y, %H:%M",
  "%d.%m.%Y, %H:%M:%S",
  "%Y%m%d_%H%M",
  "%Y%m%d_%H%M%S",
  "%y%m%d_%H%M",
  "%y%m%d_%H%M%S"
].each_with_index do |format, i|
  out += "<item uid=\"date_format_#{i+1}\" arg=\"#{format}\">"
  out += "<title>#{`echo $(date "+#{format}")`.strip}</title>"
  out += "<subtitle>Format: #{format}</subtitle>"
  out += "<icon>icon.png</icon>"
  out += "</item>\n"
end


# return results
puts "<items>#{out}</items>"