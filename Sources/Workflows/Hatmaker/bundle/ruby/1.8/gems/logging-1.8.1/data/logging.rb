
Logging.configure {

  pre_config {
    levels      %w[DEB INF PRT WRN ERR FAT]
    format_as  :inspect
  }

  logger('A::B::C') {
    level      'DEB'
    additive   false
    trace      false
    appenders  %w[stderr logfile]
  }

  logger('yourlogger') {
    level      'INF'
    appenders  %w[stderr logfile]
  }

  appender('stderr') {
    type   'Stderr'
    level  'DEB'
    layout {
      type       'Basic'
      format_as  :string
    }
  }

  appender('logfile') {
    type      'File'
    level     'DEB'
    filename  'tmp/temp.log'
    truncate  true
    layout {
      type         'Pattern'
      date_method  'to_s'
      pattern      '[%d] %l  %c : %m\n'
    }
  }

}  # logging configuration
