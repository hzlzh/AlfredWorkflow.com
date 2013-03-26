<?php

/**
 * Ping for PHP.
 *
 * This class pings a host.
 *
 * The ping() method pings a server using 'exec', 'socket', or 'fsockopen', and
 * and returns FALSE if the server is unreachable within the given ttl/timeout,
 * or the latency in milliseconds if the server is reachable.
 *
 * Example usage:
 * @code
 *   $ping = new Ping('www.example.com');
 *   $latency = $ping->ping();
 * @endcode
 *
 * @version 1.0-beta1
 * @author Jeff Geerling.
 */

class Ping {

  private $host;
  private $ttl;
  private $data = 'Ping';

  /**
   * Called when the Ping object is created.
   *
   * @param $host (string)
   *   The host to be pinged.
   * @param $ttl (int)
   *   Time-to-live (TTL) (You may get a 'Time to live exceeded' error if this
   *   value is set too low. The TTL value indicates the scope or range in which
   *   a packet may be forwarded. By convention:
   *     - 0 = same host
   *     - 1 = same subnet
   *     - 32 = same site
   *     - 64 = same region
   *     - 128 = same continent
   *     - 255 = unrestricted
   *   The TTL is also used as a general 'timeout' value for fsockopen(), so if
   *   you are using that method, you might want to set a default of 5-10 sec to
   *   avoid blocking network connections.
   *
   * @return (empty)
   */
  public function __construct($host, $ttl = 255) {
    if (!isset($host)) {
      throw new Exception("Error: Host name not supplied.");
    }

    $this->host = $host;
    $this->ttl = $ttl;
  }

  /**
   * Set the ttl (in hops).
   *
   * @param $ttl (int)
   *   TTL in hops.
   *
   * @return (empty)
   */
  public function setTtl($ttl) {
    $this->ttl = $ttl;
  }

  /**
   * Set the host.
   *
   * @param $host (string)
   *   Host name or IP address.
   *
   * @return (empty)
   */
  public function setHost($host) {
    $this->host = $host;
  }

  /**
   * Ping a host.
   *
   * @param $method (string)
   *   Method to use when pinging:
   *     - exec (default): Pings through the system ping command. Fast and
   *       robust, but a security risk if you pass through user-submitted data.
   *     - fsockopen: Pings a server on port 80.
   *     - socket: Creates a RAW network socket. Only usable in some
   *       environments, as creating a SOCK_RAW socket requires root privileges.
   *
   * @return (mixed)
   *   Latency as integer, in ms, if host is reachable or FALSE if host is down.
   */
  public function ping($method = 'exec') {
    $latency = false;

    switch ($method) {
      // The exec method uses the possibly insecure exec() function, which
      // passes the input to the system. This is potentially VERY dangerous if
      // you pass in any user-submitted data. Be SURE you sanitize your inputs!
      case 'exec':
        $ttl = escapeshellcmd($this->ttl);
        $host = escapeshellcmd($this->host);
        // Exec string for Windows-based systems.
        if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
          // -n = number of pings; -i = ttl.
          $exec_string = 'ping -n 1 -i ' . $ttl . ' ' . $host;
          $host_type = 'windows';
          $result_line = 2;
          $time_param = 4;
        }
        // Exec string for UNIX-based systems (Mac, Linux).
        else {
          // -n = numeric output; -c = number of pings; -t = ttl.
          $exec_string = 'ping -n -c 1 -t ' . $ttl . ' ' . $host;
          $host_type = 'unix';
          $result_line = 1;
          $time_param = 6;
        }
        $str = exec($exec_string, $output, $return);
        // If the result line in the output is not empty, parse it.
        if (!empty($output[$result_line])) {
          $array = explode(' ', $output[$result_line]);
          // Remove 'time=' from latency stat.
          $latency = str_replace('time=', '', $array[$time_param]);
          // If on a windows machine, also remove the 'ms'.
          if ($host_type == 'windows') {
            $latency = str_replace('ms', '', $latency);
          }
          // Convert latency to microseconds.
          $latency = round($latency);
        }
        else {
          $latency = false;
        }
        break;

      // The fsockopen method simply tries to reach the host on port 80. This
      // method is often the fastest, but not necessarily the most reliable.
      // Even if a host doesn't respond, fsockopen may still make a connection.
      case 'fsockopen':
        $start = microtime(true);
        $fp = fsockopen($this->host, 80, $errno, $errstr, $this->ttl);
        if (!$fp) {
          $latency = false;
        }
        else {
          $latency = microtime(true) - $start;
          $latency = round($latency * 1000);
        }
        break;

      // The socket method uses raw network packet data to try sending an ICMP
      // ping packet to a server, then measures the response time. Using this
      // method requires the script to be run with root privileges, though, so
      // this method only works reliably on Windows systems and on Linux servers
      // where the script is not being run as a web user.
      case 'socket':
        // Create a package.
        $type = "\x08";
        $code = "\x00";
        $checksum = "\x00\x00";
        $identifier = "\x00\x00";
        $seqNumber = "\x00\x00";
        $package = $type . $code . $checksum . $identifier . $seqNumber . $this->data;

        // Calculate the checksum.
        $checksum = $this->calculateChecksum($package); // Calculate the checksum.

        // Finalize the package.
        $package = $type . $code . $checksum . $identifier . $seqNumber . $this->data;

        // Create a socket, connect to server, then read the socket and calculate.
        if ($socket = socket_create(AF_INET, SOCK_RAW, 1)) {
          socket_connect($socket, $this->host, null);
          $start = microtime(true);
          // Send the package.
          socket_send($socket, $package, strlen($package), 0);
          if (socket_read($socket, 255) !== false) {
            $latency = microtime(true) - $start;
            $latency = round($latency * 1000);
          }
          else {
            $latency = false;
          }
          // Close the socket.
          socket_close($socket);
        }
        else {
          $latency = false;
        }
        // Close the socket.
        socket_close($socket);
        break;
    }

    // Return the latency.
    return $latency;
  }

  /**
   * Calculate a checksum.
   *
   * @param $data (string)
   *   Data for which checksum will be calculated.
   *
   * @return (string)
   *   Binary string checksum of $data.
   */
  private function calculateChecksum($data) {
    if (strlen($data)%2) {
      $data .= "\x00";
    }

    $bit = unpack('n*', $data);
    $sum = array_sum($bit);

    while ($sum >> 16) {
      $sum = ($sum >> 16) + ($sum & 0xffff);
    }

    return pack('n*', ~$sum);
  }
}
