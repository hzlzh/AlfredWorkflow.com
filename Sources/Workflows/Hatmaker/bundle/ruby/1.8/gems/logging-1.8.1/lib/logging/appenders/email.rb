
require 'net/smtp'
require 'time' # get rfc822 time format

module Logging::Appenders

  # Accessor / Factory for the Email appender.
  #
  def self.email( *args )
    return ::Logging::Appenders::Email if args.empty?
    ::Logging::Appenders::Email.new(*args)
  end

  # Provides an appender that can send log messages via email to a list of
  # recipients.
  #
  class Email < ::Logging::Appender
    include Buffering

    attr_reader :authentication, :to, :port
    attr_accessor :address, :domain, :from, :subject
    attr_accessor :user_name, :password, :enable_starttls_auto

    # call-seq:
    #    Email.new( name, :from => 'me@example.com', :to => 'you@example.com', :subject => 'Whoops!' )
    #
    # Create a new email appender that will buffer messages and then send them
    # out in batches to the listed recipients. See the options below to
    # configure how emails are sent through you mail server of choice. All the
    # buffering options apply to the email appender.
    #
    # The following options are required:
    #
    #  :from - The base filename to use when constructing new log
    #          filenames.
    #  :to   - The list of email recipients either as an Array or a comma
    #          separated list.
    #
    # The following options are optional:
    #
    #  :subject   - The subject line for the email.
    #  :address   - Allows you to use a remote mail server. Just change it
    #               from its default "localhost" setting.
    #  :port      - On the off chance that your mail server doesn't run on
    #               port 25, you can change it.
    #  :domain    - If you need to specify a HELO domain, you can do it here.
    #  :user_name - If your mail server requires authentication, set the user
    #               name in this setting.
    #  :password  - If your mail server requires authentication, set the
    #               password in this setting.
    #  :authentication - If your mail server requires authentication, you need
    #                    to specify the authentication type here. This is a
    #                    symbol and one of :plain (will send the password in
    #                    the clear), :login (will send password Base64
    #                    encoded) or :cram_md5 (combines a Challenge/Response
    #                    mechanism to exchange information and a cryptographic
    #                    Message Digest 5 algorithm to hash important
    #                    information)
    #  :enable_starttls_auto - When set to true, detects if STARTTLS is
    #                          enabled in your SMTP server and starts to use it.
    #
    # Example:
    #
    # Setup an email appender that will buffer messages for up to 1 minute,
    # and only send messages for ERROR and FATAL messages. This example uses
    # Google's SMTP server with authentication to send out messages.
    #
    #   Logger.appenders.email( 'email',
    #       :from       => "server@example.com",
    #       :to         => "developers@example.com",
    #       :subject    => "Application Error [#{%x(uname -n).strip}]",
    #
    #       :address    => "smtp.google.com",
    #       :port       => 443,
    #       :domain     => "google.com",
    #       :user_name  => "example",
    #       :password   => "12345",
    #       :authentication => :plain,
    #       :enable_starttls_auto => true,
    #
    #       :auto_flushing => 200,     # send an email after 200 messages have been buffered
    #       :flush_period  => 60,      # send an email after one minute
    #       :level         => :error   # only process log events that are "error" or "fatal"
    #   )
    #
    def initialize( name, opts = {} )
      opts[:header] = false
      super(name, opts)

      af = opts.getopt(:buffsize) ||
           opts.getopt(:buffer_size) ||
           100
      configure_buffering({:auto_flushing => af}.merge(opts))

      # get the SMTP parameters
      self.from = opts.getopt :from
      raise ArgumentError, 'Must specify from address' if @from.nil?

      self.to = opts.getopt :to
      raise ArgumentError, 'Must specify recipients' if @to.empty?

      self.subject   = opts.getopt :subject, "Message from #{$0}"
      self.address   = opts.getopt(:server) || opts.getopt(:address) || 'localhost'
      self.port      = opts.getopt(:port, 25)
      self.domain    = opts.getopt(:domain, ENV['HOSTNAME']) || 'localhost.localdomain'
      self.user_name = opts.getopt(:acct) || opts.getopt(:user_name)
      self.password  = opts.getopt(:passwd) || opts.getopt(:password)
      self.enable_starttls_auto = opts.getopt(:enable_starttls_auto, false)
      self.authentication = opts.getopt(:authtype) || opts.getopt(:authentication) || :plain
    end

    # Close the email appender. If the layout contains a foot, it will not be
    # sent as an email.
    #
    def close( *args )
      super(false)
    end

    # If your mail server requires authentication, you need to specify the
    # authentication type here. This is a symbol and one of :plain (will send
    # the password in the clear), :login (will send password Base64 encoded)
    # or :cram_md5 (combines a Challenge/Response mechanism to exchange
    # information and a cryptographic Message Digest 5 algorithm to hash
    # important information)
    #
    def authentication=( val )
      @authentication = val.to_s.to_sym
    end

    # On the off chance that your mail server doesn't run on port 25, you can
    # change it.
    #
    def port=( val )
      @port = Integer(val)
    end

    # The list of email recipients. This can either be an Array of recipients
    # or a comma separated list. A single recipient is also valid.
    #
    #   email.to = ['mike@example.com', 'tony@example.com']
    #   email.to = 'alicia@example.com'
    #   email.to = 'bob@example.com, andy@example.com, john@example.com'
    #
    def to=( val )
      @to = val.respond_to?(:split) ?  val.split(',') : Array(val)
    end


  private

    # This method is called by the buffering code when messages need to be
    # sent out as an email.
    #
    def canonical_write( str )
      ### build a mail header for RFC 822
      rfc822msg =  "From: #{@from}\n"
      rfc822msg << "To: #{@to.join(",")}\n"
      rfc822msg << "Subject: #{@subject}\n"
      rfc822msg << "Date: #{Time.new.rfc822}\n"
      rfc822msg << "Message-Id: <#{"%.8f" % Time.now.to_f}@#{@domain}>\n\n"

      rfc822msg = rfc822msg.force_encoding(encoding) if encoding and rfc822msg.encoding != encoding
      rfc822msg << str

      ### send email
      smtp = Net::SMTP.new(@address, @port)
      smtp.enable_starttls_auto if @enable_starttls_auto and smtp.respond_to? :enable_starttls_auto
      smtp.start(@domain, @user_name, @password, @authentication) { |s| s.sendmail(rfc822msg, @from, @to) }
      self
    rescue StandardError, TimeoutError => err
      self.level = :off
      ::Logging.log_internal {'e-mail notifications have been disabled'}
      ::Logging.log_internal(-2) {err}
    end

  end   # Email
end   # Logging::Appenders

