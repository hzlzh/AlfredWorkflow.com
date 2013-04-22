
Logging.configure {

  logger(:root) {
    level      :info
    appenders  'logfile'
  }

  appender('logfile') {
    type      'File'
    level     'DEB'
    filename  'tmp/temp.log'
    truncate  true
    layout {
      type         'BadLayout'
      date_method  'to_s'
      pattern      '[%d] %l  %c : %m\n'
    }
  }

}  # logging configuration
