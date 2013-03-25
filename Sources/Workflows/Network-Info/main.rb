load 'alfred_feedback.rb'

netinfo = `networksetup -listnetworkserviceorder | grep Hardware`
interfaces = []
netinfo.each_line do |line|
  parts = line.split(',')
  port = parts[0].split(':')[1].strip
  device = parts[1].split(':')[1].strip[0..-2]
  interfaces << {:device => device, :port => port}
end
interfaces.each do |interface|
  ip = `ipconfig getifaddr "#{interface[:device]}"`.strip
  interface[:ip] = ip
  mac = `ifconfig "#{interface[:device]}" 2> /dev/null | grep ether | awk '{print $2}'`.strip
  interface[:mac] = mac
end

feedback = Feedback.new
if ARGV[0] == 'ip'
	external_ip = `curl --silent http://icanhazip.com`.strip
	feedback.add_item({:title => "External IP: #{external_ip}", :subtitle => 'Press Enter to paste, or Cmd+Enter to copy', :arg => external_ip})
	interfaces.each do |interface|
		ip = interface[:ip]
		name = interface[:port]
		device = interface[:device]
		if !ip.nil? && ip.length > 0
			feedback.add_item({:title => "Local #{name} (#{device}) IP: #{ip}", :subtitle => 'Press Enter to paste, or Cmd+Enter to copy', :arg => ip})
		end
	end
else
	interfaces.each do |interface|
		mac = interface[:mac]
		name = interface[:port]
		device = interface[:device]
		if !mac.nil? && mac.length > 0
			feedback.add_item({:title => "#{name} (#{device}) MAC: #{mac}", :subtitle => 'Press Enter to paste, or Cmd+Enter to copy', :arg => mac})
		end
	end
end
puts feedback.to_xml