require 'socket'
require 'timeout'

module PortChecker
  def self.open?(port, host='localhost', seconds=1)
    Timeout::timeout(seconds) do
      begin
        TCPSocket.new(host, port).close
        true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        false
      end
    end
  rescue Timeout::Error
    false
  end

  def self.first_available(range)
    for port in range
      return port unless open? port
    end
  end
end
