
Logging.configure {

  logger(:root) {
    level      :info
    appenders  'stdout'
  }

  appender('stdout') {
    type 'Stdout'
  }

}  # logging configuration
