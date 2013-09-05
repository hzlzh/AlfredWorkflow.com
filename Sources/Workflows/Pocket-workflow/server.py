import SimpleHTTPServer
import SocketServer
# Server port
import logging
import os
import signal
import sys
import pocket


logger = pocket.logger

PORT = 2222

class ServerHandler(SimpleHTTPServer.SimpleHTTPRequestHandler):
	def do_GET(self):
		logger.info("received a connection")
		pocket.getAuthToken()
		logger.info('Stopping servers')
		SimpleHTTPServer.SimpleHTTPRequestHandler.do_GET(self)
		sys.stdout.write("Welcome!")
		httpd.socket.close()
		logger.info('Stopping servers 2')
		processes = os.popen("ps -eo pid,command | grep server.py | grep -v grep | awk '{print $1}'").read().splitlines()
		logger.info('Processes pids : '+ " ".join(processes))
		for pid in processes:
			logger.info('Trying to stop proccess with the id ' + pid)
			cmd = os.kill(int(pid),signal.SIGTERM)
			logger.info('Success shutting down proccess')

# Initialize server object
httpd = SocketServer.TCPServer(("", PORT), ServerHandler)
#print "serving at port", PORT
logger.info("Server started at 2222")
httpd.serve_forever()