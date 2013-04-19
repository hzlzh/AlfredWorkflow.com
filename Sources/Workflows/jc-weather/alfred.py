#!/usr/bin/python
# coding=UTF-8

import plistlib
import os.path

preferences = plistlib.readPlist('info.plist')
bundleid = preferences['bundleid']
cache_dir = os.path.expanduser('~/Library/Caches'
                               '/com.runningwithcrayons.Alfred-2'
                               '/Workflow Data/{}'.format(bundleid))
data_dir = os.path.expanduser('~/Library/Application Support/Alfred 2'
                              '/Workflow Data/{}'.format(bundleid))


class Item(object):
    '''An item in an Alfred feedback XML message'''
    def __init__(self, uid, title, subtitle=None, icon=None, valid=False,
                 arg=None):
        self.uid = uid
        self.title = title
        self.subtitle = subtitle
        self.valid = valid
        self.arg = arg
        self.icon = icon if icon is not None else 'icon.png'

    def to_xml(self):
        attrs = []

        attrs.append('uid="{}-{}"'.format(bundleid, self.uid))

        if self.valid:
            attrs.append('valid="yes"')
        else:
            attrs.append('valid="no"')

        if self.arg is not None:
            attrs.append(u'arg="{}"'.format(self.arg))

        xml = [u'<item {}>'.format(u' '.join(attrs))]

        xml.append(u'<title>{}</title>'.format(self.title))

        if self.subtitle is not None:
            xml.append(u'<subtitle>{}</subtitle>'.format(self.subtitle))
        if self.icon is not None:
            xml.append(u'<icon>{}</icon>'.format(self.icon))

        xml.append(u'</item>')
        return ''.join(xml)


def to_xml(items):
    '''Convert a list of Items to an Alfred XML feedback message'''
    msg = [u'<?xml version="1.0"?>', u'<items>']

    for item in items:
        msg.append(item.to_xml())

    msg.append(u'</items>')
    return u''.join(msg)


def get_from_user(title, prompt, hidden=False, value=None):
    '''
    Popup a dialog to request some piece of information.

    The main use for this function is to request information that you don't
    want showing up in Alfred's command history.
    '''
    if value is None:
        value = ''

    script = '''
        on run argv
          tell application "Alfred 2"
              activate
              set alfredPath to (path to application "Alfred 2")
              set alfredIcon to path to resource "appicon.icns" in bundle ¬
                (alfredPath as alias)

              set dlgTitle to (item 1 of argv)
              set dlgPrompt to (item 2 of argv)

              if (count of argv) is 3
                set dlgHidden to (item 3 of argv as boolean)
              else
                set dlgHidden to false
              end if

              if dlgHidden
                display dialog dlgPrompt & ":" with title dlgTitle ¬
                  default answer "{v}" with icon alfredIcon with hidden answer
              else
                display dialog dlgPrompt & ":" with title dlgTitle ¬
                  default answer "{v}" with icon alfredIcon
              end if

              set answer to text returned of result
          end tell
        end run'''.format(v=value)

    from subprocess import Popen, PIPE
    cmd = ['osascript', '-', title, prompt]
    if hidden:
        cmd.append('true')
    p = Popen(cmd, stdin=PIPE, stdout=PIPE, stderr=PIPE)
    stdout, stderr = p.communicate(script)
    return stdout.rstrip('\n')


def show_message(title, message):
    '''Display a message dialog'''
    script = '''
        on run argv
          tell application "Alfred 2"
              activate
              set alfredPath to (path to application "Alfred 2")
              set alfredIcon to path to resource "appicon.icns" in bundle ¬
                (alfredPath as alias)

              set dlgTitle to (item 1 of argv)
              set dlgMessage to (item 2 of argv)

              display dialog dlgMessage with title dlgTitle buttons ¬
                {"OK"} default button "OK" with icon alfredIcon
          end tell
        end run'''

    from subprocess import Popen, PIPE
    cmd = ['osascript', '-', title, message]
    p = Popen(cmd, stdin=PIPE, stdout=PIPE, stderr=PIPE)
    p.communicate(script)


if __name__ == '__main__':
    from sys import argv
    globals()[argv[1]](*argv[2:])
