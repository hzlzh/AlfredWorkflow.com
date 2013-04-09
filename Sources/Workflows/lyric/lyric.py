#!/usr/bin/env python
# -*- coding: utf-8 -*-
#! 强制默认编码为utf-8
import sys
reload(sys)
sys.setdefaultencoding('utf8')

import os, urllib, urllib2, subprocess, json, re, codecs
from base64 import b64encode, b64decode
from xml.dom import minidom

import alfred

from pprint import pprint

class Lyric(object):
    def __init__(self):
        self.cache = alfred.Cache()

    def run(self):
        cmd_map = {
            'search'            : lambda: self.search(),
            'output-clean'      : lambda: self.outputCleanContent(),
            'download'          : lambda: self.download(),
            'save-to-itunes'    : lambda: self.saveLyricToiTunes()
        }
        cmd = alfred.argv(1)
        if not cmd:
            cmd = 'search'
        if cmd in cmd_map.keys():
            cmd_map[cmd]()

    def search(self):
        title = alfred.argv(2)
        artist = alfred.argv(3)
        if title is None:
            self.outputiTunesPlayingSong()
        res, data = self.fetchLyricList(title, artist)
        if not res:
            alfred.exitWithFeedback(
                title       = data,
                subtitle    = "Format: lrc TITLE ARTIST e.g. lrc 'Heal The World' 'Michael Jackson'"
                )
        feedback = alfred.Feedback()
        for lrc in data:
            feedback.addItem(
                title   = '{artist} - {title}'.format(**lrc),
                arg     = lrc['id']
                )
        feedback.output()

    def outputiTunesPlayingSong(self):
        res, data = self.fetchiTunesPlaying()
        if not res or not data['title']:
            return
        title = '{title}' if not data['artist'] else '{artist} - {title}'
        title = title.format(**data)
        alfred.exitWithFeedback(
            title       = title,
            subtitle        = 'iTunes current playing track',
            autocomplete    = '"{title}" "{artist}"'.format(**data),
            valid           = False
            )

    def fetchiTunesPlaying(self):
        try:
            res = subprocess.check_output(['osascript', 'itunes.applescript'])
            if not res:
                return False, ''
            info = map(lambda s: s.strip(), res.split(','))
            code = int(info[0])
            if code != 0:
                return False, info[1]
            return True, {'artist': info[1], 'title' : info[2]}
        except Exception, e:
            return False, '{}'.format(e)

    def fetchLyricList(self, title, artist = ''):
        if not title:
            return False, 'Song title missing.'
        if artist is None:
            artist = ''
        # 缓存结构 { 'query' : {'title': '', 'artist': ''}, 'list'  : [] }
        cache = self.cache.get('lyric-list')
        if cache and cache['query']['title'] == title and cache['query']['artist'] == artist:
            return True, cache['list']
        try:
            paras = {
                'Title'     : subprocess.check_output(['php', '-f', 'ttplayer.php', 'sh', title]),
                'Artist'    : subprocess.check_output(['php', '-f', 'ttplayer.php', 'sh', artist]),
                'Flags'     : 0
            }
            url = 'http://lrccnc.ttplayer.com/dll/lyricsvr.dll?sh?{}'.format(urllib.urlencode(paras))
            res = urllib2.urlopen(url)
            dom = minidom.parse(res)
            lrcs = dom.documentElement.getElementsByTagName('lrc')
            if len(lrcs) == 0:
                return False, 'Lyric is non-existent.'
            data = []
            for lrc in lrcs:
                data.append({
                    'id'        : lrc.getAttribute('id'),
                    'artist'    : lrc.getAttribute('artist'),
                    'title'     : lrc.getAttribute('title')
                })
            cache = {
                'query' : {'title' : title, 'artist' : artist},
                'list'  : data
            }
            self.cache.set('lyric-list', cache)
            return True, data
        except Exception, e:
            return False, '{}'.format(e)

    def fetchLyricContent(self, lyric_id):
        if not lyric_id:
            return False, 'Lyric is non-existent.'
        # 缓存结构 { 'id' : '', 'content' : ''}
        cache = self.cache.get('lyric-content')
        if cache and cache['id'] == lyric_id:
            return True, cache['content']
        info = self.getLyricInfoFromCache(lyric_id)
        if info is None:
            return False, 'Lyric is non-existent.'
        try:
            paras = {
                'id'    : info['id'],
                'code'  : subprocess.check_output(['php', '-f', 'ttplayer.php', 'dl', info['id'], info['artist'], info['title']])
            }
            #! Id必须在Code之前 不能用urllib.urlencode
            url = 'http://lrccnc.ttplayer.com/dll/lyricsvr.dll?dl?Id={id}&Code={code}'.format(**paras)
            res = urllib2.urlopen(url)
            content = res.read()
            cache = {
                'id'        : lyric_id,
                'content'   : content
            }
            self.cache.set('lyric-content', cache)
            return True, content
        except Exception, e:
            return False, '{}'.format(e)

    def cleanLyricTimeline(self, lrc):
        new_lrc = ''
        last_line_empty = False
        for line in lrc.splitlines():
            while re.search(r'^\[(.+?)\]', line):
                line = re.sub(r'^\[(.+?)\]', '', line)
            # 去除QQ
            line = re.sub(r'(.*)QQ[:： ](.*)', '', line)
            line = line.strip()
            if last_line_empty and not line:
                continue
            last_line_empty = True if not line else False
            new_lrc += '{}\n'.format(line.strip())
        return new_lrc.strip()

    def getLyricInfoFromCache(self, lrc_id):
        cache = self.cache.get('lyric-list')
        if not cache:
            return
        for lrc in cache['list']:
            if lrc['id'] == lrc_id:
                return lrc

    def getCleanLyricContent(self):
        lrc_id = alfred.argv(2)
        res, data = self.fetchLyricContent(lrc_id)
        if not res:
            return
        return self.cleanLyricTimeline(data)
            
    def outputCleanContent(self):
        alfred.exit(self.getCleanLyricContent())

    def download(self):
        lrc_id = alfred.argv(2)
        info = self.getLyricInfoFromCache(lrc_id)
        if info is None:
            alfred.exit('Lyric is non-existent.')
        res, data = self.fetchLyricContent(lrc_id)
        if not res:
            alfred.exit(data)
        try:
            filename = '{title}.lrc' if not info['artist'] else '{artist} - {title}.lrc'
            dl_path = os.path.expanduser('~/Downloads')
            dl_path = os.path.join(dl_path, filename.format(**info))
            with codecs.open(dl_path, 'w', 'utf-8') as f:
                f.write(data)
            if os.path.exists(dl_path):
                subprocess.check_output(['open', os.path.dirname(dl_path)])
            alfred.exit('Lyric downloaded.')
        except Exception, e:
            alfred.exit('Download lyric fail. {}'.format(e))

    def saveLyricToiTunes(self):
        lrc = self.getCleanLyricContent()
        if not lrc:
            alfred.exit('Fail: lyric is non-existent.')
        # lrc = 'test'
        res = subprocess.check_output('osascript itunes.applescript lyric "{}"'.format(lrc), shell=True)
        info = map(lambda s: s.strip(), res.split(','))
        code = int(info[0])
        if code != 0:
            alfred.exit('Fail: {}'.format(info[1]))
        alfred.exit('Lyric saved to {} - {}.'.format(info[1], info[2]))

if __name__ == '__main__':
    Lyric().run()
        