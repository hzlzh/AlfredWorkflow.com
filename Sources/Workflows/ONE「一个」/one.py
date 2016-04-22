#!/usr/bin/python
#coding=utf-8
#
#
# Copyright (c) 2016 fusijie <fusijie@vip.qq.com>
#
# MIT Licence. See http://opensource.org/licenses/MIT
#
# Created on 2016-04-22
#

import sys
import os
from workflow import Workflow, web

reading_url = 'http://v3.wufazhuce.com:8000/api/reading/index'
essay_url_prefix = 'http://wufazhuce.com/article/'
serial_url_prefix = 'http://m.wufazhuce.com/serial/'
question_url_prefix = 'http://wufazhuce.com/question/'
default_thumsnail = 'icon.png'

def _get_reading_url():
    return reading_url

def _parse_reading():
    data = web.get(_get_reading_url()).json()
    return data

def _get_thumbnail():
    return default_thumsnail

def _get_reading(wf):
    data = wf.cached_data('one_reading', _parse_reading, max_age = 30)
    reading_data = data['data']
    if sys.argv[1] == 'essay':
        essays = reading_data['essay']
        for essay in essays:
            essay_title = essay['hp_title']
            essay_subtitle = essay['guide_word']
            essay_thumbnail = essay['author'][0]['web_url']
            essay_url = essay_url_prefix + essay['content_id']
            wf.add_item(title = essay_title, subtitle = essay_subtitle, icon = _get_thumbnail(), arg = essay_url, valid = True)
        wf.send_feedback()
    elif sys.argv[1] == 'serial':
        serials = reading_data['serial']
        for serial in serials:
            serial_title = serial['title']
            serial_subtitle = serial['excerpt']
            serial_thumbnail = serial['author']['web_url']
            serial_url = serial_url_prefix + serial['id']
            wf.add_item(title = serial_title, subtitle = serial_subtitle, icon = _get_thumbnail(), arg = serial_url, valid = True)
        wf.send_feedback()
    elif sys.argv[1] == 'question':
        questions = reading_data['question']
        for question in questions:
            question_title = question['question_title']
            question_subtitle = question['answer_content']
            question_url = question_url_prefix + question['question_id']
            wf.add_item(title = question_title, subtitle = question_subtitle, icon = _get_thumbnail(), arg = question_url, valid = True)
        wf.send_feedback()

def main(wf):
    try:
        _get_reading(wf)
    except:
        pass

if __name__ == '__main__':
    wf = Workflow()
    sys.exit(wf.run(main))