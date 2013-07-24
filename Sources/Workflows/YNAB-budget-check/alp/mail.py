# -*- coding: utf-8 -*-

import smtplib
from email.mime.text import MIMEText


class Mail(object):
    def __init__(self, host, port, SSL, user, pw, sender, to, mimetype, subject, body):
        self.host = host
        self.port = port
        self.SSL = SSL
        self.user = user
        self.pw = pw
        self.sender = sender
        self.to = to
        self.mimetype = mimetype if mimetype else "plain"
        self.subject = subject
        self.body = body

    def _mime(self, to, subject, body):
        text = MIMEText(body.encode("utf-8"), self.mimetype, "utf-8")
        text["From"] = self.sender.encode("utf-8")
        text["Subject"] = subject.encode("utf-8")
        text["To"] = to.encode("utf-8")

        return text.as_string().encode("utf-8")

    def notify(self):
        server = smtplib.SMTP_SSL(self.host, self.port) if self.SSL else smtplib.SMTP(self.host, self.port)
        if not self.user == None and not self.pw == None:
            server.login(self.user, self.pw)
        if 'gmail' in self.host:
            server.ehlo()
            server.starttls()

        def sendMessage(to):
            body = self.body
            subject = self.subject
            message = self._mime(to, subject, body)
            server.sendmail(self.sender, to, message)

        if isinstance(self.to, list):
            for to in self.to:
                sendMessage(to)
        else:
            sendMessage(self.to)
