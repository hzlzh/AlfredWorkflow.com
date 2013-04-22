
Logging.configure {

  logger(:root) {
    level      :info
    appenders  'bad'
  }

  appender('bad') {
    type 'FooBar'
  }

}  # logging configuration
