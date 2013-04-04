#!/usr/bin/python
# coding=UTF-8
# Filename: feedback.py

import sys, os, inspect, re
reload(sys)
sys.setdefaultencoding('utf8')
workdir = os.path.realpath(os.path.abspath(os.path.join(os.path.split(inspect.getfile( inspect.currentframe() ))[0],"iambus_xunlei_lixian")))
sys.path.insert(0, workdir)

from lixian_cli_parser import *
from lixian_config import get_config
from lixian_config import LIXIAN_DEFAULT_COOKIES
from lixian_commands.util import *
from lixian_util import format_size
import lixian_help
import lixian_query
import alp
from alp.item import Item as alp_item

@command_line_parser(help=lixian_help.list)
@command_line_option('all', default=True)
@command_line_option('completed')
@command_line_option('deleted')
@command_line_option('expired')
@command_line_value('category')
@command_line_option('id', default=get_config('id', True))
@command_line_option('name', default=True)
@command_line_option('status', default=True)
@command_line_option('dcid')
@command_line_option('gcid')
@command_line_option('original-url')
@command_line_option('download-url')
@command_line_option('speed')
@command_line_option('progress')
@command_line_option('date')
@command_line_option('n', default=get_config('n'))
@command_line_value('username', default=get_config('username'))
@command_line_value('password', default=get_config('password'))
@command_line_value('cookies', default=LIXIAN_DEFAULT_COOKIES)

def query_task(args):

    parent_ids = [a[:-1] for a in args if re.match(r'^#?\d+/$', a)]
    if parent_ids and not all(re.match(r'^#?\d+/$', a) for a in args):
        print parent_ids
        print args
        raise NotImplementedError("Can't mix 'id/' with others")
    assert len(parent_ids) <= 1, "sub-tasks listing only supports single task id"
    ids = [a[:-1] if re.match(r'^#?\d+/$', a) else a for a in args]

    client = create_client(args)
    if parent_ids:
        args[0] = args[0][:-1]
        tasks = lixian_query.search_tasks(client, args)
        assert len(tasks) == 1
        tasks = client.list_bt(tasks[0])
        tasks.sort(key=lambda x: int(x['index']))
    else:
        tasks = lixian_query.search_tasks(client, args)
        if len(args) == 1 and re.match(r'\d+/', args[0]) and len(tasks) == 1 and 'files' in tasks[0]:
            parent_ids = [tasks[0]['id']]
            tasks = tasks[0]['files']

    output_feedbackItems(tasks, not parent_ids)

def output_feedbackItems(tasks, top=True):
    # --name --no-id  --size --status --progress --download-url --n
    # n: t['#']
    # name: t['name'].encode(default_encoding)
    # size: from lixian_util import format_size
    #       format_size(t['size'])
    # progress: t['progress']
    # download-url: t['xunlei_url']

    items = []
    for i, t in enumerate(tasks):
        # [Task_Name: progress]
        isBT = True if t['type'] == 'bt' else False
        seqNum = str(t['#'] if top else t.get('index', t['id']))
        feedTitle = ' '.join([seqNum, t['name']])
        subTitles = [format_size(t['size']), t['status_text'], t['progress']]
        feedsubTitle = ' '.join(str(subT) for subT in subTitles)
        d_url = t['xunlei_url']
        items.append(alp_item(title=feedTitle,
                                subtitle=feedsubTitle,
                                arg=(str(t['#']) + '/' if top and isBT else d_url),
                                # autocomplete=(str(t['#']) + '/@' if top and isBT else ''),
                                fileType = True if top and isBT else False,
                                icon = 'org.bittorrent.torrent' if top and isBT else 'icon.png',
                                valid=True))


    if len(items):
        alp.feedback(items)
    else:
        alp.feedback(alp_item(title="没有找到",
                                subtitle="修改[关键字]，或使用 [ID]来检索",
                                valid=False,
                                fileIcon=True,
                                icon="/System/Library/CoreServices/Problem Reporter.app"))



if __name__ == "__main__":
    query_task(sys.argv[1:])

    '''
    # check input，start query when type @
    suffix = '@'
    keyword = str(sys.argv[1])
    if keyword.endswith(suffix, 1):
        sys.argv[1] = keyword[:-1]
        query_task(sys.argv)
    else:
        alp.feedback(alp_item(title="以[@]结尾，开始检索", subtitle="可使用：[ID]、[关键字]、[0-10]等格式", valid=False))
    '''